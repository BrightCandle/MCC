if (isDedicated || MCC_isLocalHC) exitWith {}; // not a player machine

// Basicly wait till mission start
while { (isnil ("MCC_TRAINING"))  } do {sleep 3};
while { true } do {
	"RESPAWN_GUERRILA" setMarkerPosLocal [-9999, -9999, 0.5];
	"RESPAWN_EAST" setMarkerPosLocal [-9999, -9999, 0.5];
	"RESPAWN_WEST" setMarkerPosLocal [-9999, -9999, 0.5];
	"RESPAWN_CIVILIANS" setMarkerPosLocal [-9999, -9999, 0.5];

	while { (isNull player) || (alive player) } do {sleep 1};

    waitUntil { (alive player) && (player isKindOf "CAManBase") };

	cutText ["You Died...","BLACK OUT",2];

	sleep 1;
	player setCaptive true;
	if (isnil "MCC_deadGroup") then {MCC_deadGroup = createGroup civilian; publicVariable "MCC_deadGroup"};
	[player] join MCC_deadGroup;
	player attachto [MCC_respawnAnchor,[2,2,2]];
	sleep 2;
	
	[] spawn {
	waitUntil {inputAction "revealTarget" > 0};  
	["Terminate"] call BIS_fnc_EGSpectator;
	};

	["Initialize", [player, [], true, true, true, true, true, true, true, true]] call BIS_fnc_EGSpectator;
	_ret = [true] call acre_api_fnc_setSpectator;
	
	cutText ["","BLACK IN",2];
};
