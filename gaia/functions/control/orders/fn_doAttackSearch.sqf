//==================================================================fnc_DoAttackSearch=======================================================================================
// Generate a search and destroy waypoint a minimum distance away at a random front arc to the target
// Example: [_group,_targetpos,_minimumDistanceForWaypoint] call fnc_DoAttackSearch
// BrightCandle
//===========================================================================================================================================================================
private ["_group","_TargetPos","_pos","_Degree","_NrOfBuildingWp"];

_group 			= _this select 0;
_TargetPos	=	_this select 1;
_minimumDistance = _this select 2;

_pos 			= (position leader _group);

[_group] call GAIA_fnc_removeWaypoints;

_angle = random [-90,0,90];
_direction = (_TargetPos getDir _pos) + _angle;

_waypointLocation = _TargetPos getPos [_minimumDistance,_direction];

_dummy	=[_group,_waypointLocation, "SAD"] call GAIA_fnc_addAttackWaypointCar;

((count (waypoints _group)) - currentWaypoint _group)
