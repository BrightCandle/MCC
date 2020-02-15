/*
	Takes a unit and puts it into guard mode, they will stay in place and adopt a stance that is either standing or a prior set stance
*/

params ["_unit",["_stances",[]]];

_requestedPos = unitPos _unit;
if (_requestedPos== "AUTO") then {
	_requestedPos = "UP";
};

_requestedStances = [];
if ((count _stances) == 0) then {
	switch (_requestedPos) do {
		case "Up": {_requestedStances=["STAND"]};
		case "Middle": {_requestedStances=["CROUCH"]};
		case "Down": {_requestedStances=["PRONE"]};
		default { _requestedStances=["STAND"] };
	};
} else {
	_requestedStances = _stances;
};

_unit disableAI "MOVE";
_unit setVariable ["dangerAIEnabled",false]; //Lambs.danger mod disable FSM
_unit enableAttack false;

_unit setVariable ["MCC_CF_Stances", _requestedStances ];

_unit addEventHandler ["AnimStateChanged",{
	params ["_unit", "_anim"];

	_requestedStances = _unit getVariable ["MCC_CF_Stances",["STAND"] ];

	if !((stance _unit) in _requestedStances) then {
		_requestedPos="UP";

		switch (_requestedStances select 0) do {
			case "STAND": {_requestedPos="UP"};
			case "CROUCH": {_requestedPos="MIDDLE"};
			case "PRONE": {_requestedPos="DOWN"};
			default { _requestedPos="UP"};
		};

		_unit setUnitPos (_requestedPos);
	};
}];