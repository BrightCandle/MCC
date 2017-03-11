//==================================================================fnc_DoInfPatrol===============================================================================================
// Generate some stuff to do for our attack
// Example: [_group,_targetpos] call fnc_DoAttackInf
// spirit 20-1-2014
//===========================================================================================================================================================================
private ["_group","_TargetPos","_pos","_Degree","_NrOfBuildingWp"];

_group 			= _this select 0;
_TargetPos	=	_this select 1;

_minimumDistance = random [200,300,500];

[_group,_TargetPos, _minimumDistance] call GAIA_fnc_doAttackSearch;
