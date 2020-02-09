/* ----------------------------------------------------------------------------
Function: CBA_fnc_taskDefend
Description:
    A function for a group to defend a parsed location.
    Units will mount nearby static machine guns and bunker in nearby buildings.
    They may also patrol the radius unless otherwise specified.
Parameters:
    - Group (Group or Object)
Optional:
    - Position (XYZ, Object, Location or Group)
    - Defend Radius (Scalar)
    - Building Size Threshold (Integer, default 2)
Example:
    (begin example)
    [this] call CBA_fnc_taskDefend
    (end)
Returns:
    Nil
Author:
    Rommel, SilentSpike, BrightCandle
---------------------------------------------------------------------------- */

params [
    ["_group",grpNull,[grpNull,objNull]],
    ["_position",[],[[],objNull,grpNull,locationNull],3],
    ["_radius",50,[0]],
    ["_threshold",1,[0]]
];

_group = _group call CBA_fnc_getGroup;
if !(local _group) exitWith {}; // Don't create waypoints on each machine

_position = [_position,_group] select (_position isEqualTo []);
_position = _position call CBA_fnc_getPos;

private _statics = _position nearObjects ["StaticWeapon", _radius];
private _buildings = _position nearObjects ["Building", _radius];

// Filter out occupied statics
_statics = _statics select {(_x emptyPositions "Gunner") > 0};

// Filter out buildings below the size threshold (and store positions for later use)
_buildings = _buildings select {
    private _positions = _x buildingPos -1;
    private _postionCount = count (_positions);

    if (isNil {_x getVariable "CBA_taskDefend_positions"}) then {
        _x setVariable ["CBA_taskDefend_positions", _positions];
    };

    if (isNil {_x getVariable "CBA_taskDefend_remainingPositions"}) then {
        _x setVariable ["CBA_taskDefend_remainingPositions", _postionCount];
    };

    _postionCount > _threshold
};

private _units = units _group;

GAIA_taskDefend_FNC_chooseBuilding = {
	params ["_buildings"];
	
	private _building = nil;
	while { (! (_buildings isEqualto [])) && {isNil "_building"} } do {
		_building = _buildings call BIS_fnc_selectRandom;
		
		private _buildingRemainingPositions = _building getVariable ["CBA_taskDefend_remainingPositions",0];
		private _buildingHasSpace = _buildingRemainingPositions > 0;

		if(_buildingHasSpace) then {
			_building setVariable ["CBA_taskDefend_remainingPositions",_buildingRemainingPositions -1];
		} else {
			_building=nil;
		};
	};
	
	if !(isNil "_building") then {
		_building;
	}
};

GAIA_taskDefend_FNC_releaseBuilding = {
	params ["_building"];
	
	private _buildingRemainingPositions = _building getVariable ["CBA_taskDefend_remainingPositions",0];
	_building setVariable ["CBA_taskDefend_remainingPositions",_buildingRemainingPositions +1];
};

GAIA_taskDefend_FNC_releasePosition = {
	params ["_building","_position"];
	
	private _positions = _building getVariable ["CBA_taskDefend_positions",[]];
	_positions pushBack _position;
};

GAIA_taskDefend_FNC_closeToPosition = {
	params ["_pos1","_pos2"];

	(abs((_pos1 select 0) - (_pos2 select 0)) <2) && 
		   (abs((_pos1 select 1) - (_pos2 select 1)) <2) && 
		   (abs((_pos1 select 2) - (_pos2 select 2)) <2);
};

GAIA_taskDefend_FNC_moveToPosition = {
	params ["_unit","_building","_teleportMove"];
	private _positions = _building getVariable ["CBA_taskDefend_positions",[]];

	if !(_positions isEqualTo []) then {
		private _pos = _positions deleteAt (floor(random(count _positions)));
		
		private _previousPos = _unit getVariable "CBA_taskDefend_pos";
		
		if !(isNil "_previousPos") then {
			[_building,_previousPos] call GAIA_taskDefend_FNC_releasePosition;
		};

		_building setVariable ["CBA_taskDefend_positions",_positions];

		_unit setVariable ["CBA_taskDefend_pos",_pos];

		//Workaround for units failing to find a path to move and appearing in the floor.
		if (_teleportMove) then {
			_unit setPos _pos;
		} else {
			_unit enableai "move";
			_unit doMove _pos;
			waituntil {(unitReady _unit)};

			isClose = [getPos _unit ,_pos] call GAIA_taskDefend_FNC_closeToPosition;
			if isClose then {
				_unit setPos _pos;
			};
		};
		
		_unit disableai "move";
		doStop _unit;
	};
};

GAIA_taskDefend_FNC_inCombat = {
	params ["_unit"];

	private _assignedTarget = assignedTarget _unit;
    
	!isNull _assignedTarget;
};

{

	_x setVariable ["dangerAIEnabled",false];
	_x enableAttack false; 
	
    if (!(_statics isEqualto []) ) then {
        _x assignAsGunner (_statics deleteAt 0);
        [_x] orderGetIn true;
    } else {
		[_x, _buildings] spawn {
			params ["_unit","_buildings"];
			private _isSpawnedAlready = _unit getVariable ["CBA_taskDefend_isRunning",false];

			if(_isSpawnedAlready) exitWith {
				true;
			};

			_unit setVariable ["CBA_taskDefend_isRunning",true];

			private _building= [_buildings] call GAIA_taskDefend_FNC_chooseBuilding;

			[_unit,_building,true] call GAIA_taskDefend_FNC_moveToPosition;//teleports them into position first time.
	
			if (!(isNil "_building")) then {

				while {alive _unit} do {
					[_unit] call CBA_fnc_clearWaypoints;
					
					[_unit,_building,false] call GAIA_taskDefend_FNC_moveToPosition;
					
					sleep( random [3,6,30] );

					private _inCombat = [_unit] call GAIA_taskDefend_FNC_inCombat;

					if((!_inCombat) && ((random 1)> 0.99) ) then {
						[_building] call GAIA_taskDefend_FNC_releaseBuilding;
						_building= [_buildings] call GAIA_taskDefend_FNC_chooseBuilding;
					};
				};
				//release position when dead
				_pos = _unit getVariable "CBA_taskDefend_pos";
				if !(isNil "_pos" || isNil "_building") then {
					[_building,_pos] call GAIA_taskDefend_FNC_releasePosition;
				};
			};
		};
    };
} forEach _units;