params ["_waypoint","_group","_position"];

[_waypoint,_group,_position] spawn {
	params ["_waypoint","_group","_wpPos"];

	_distance = (leader _group) distance _wpPos;
	_distance = ((_distance)/1000.0) max 1.0;

	sleep (_distance * 200);
	_currentWPs = waypoints _group;

	_newPos = getWPPos (_currentWPs select 0);

	if (_wpPos isEqualTo _newPos) then {
		[_group] call GAIA_fnc_removeWaypoints;
	};
};