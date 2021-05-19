/*
	Takes a unit and makes it surrender the moment a shot comes near it.
*/

params ["_unit"];

waitUntil {getSuppression _unit >= 0.01};
["ACE_captives_setSurrendered", [_unit, true], _unit] call CBA_fnc_targetEvent;