local characterSelector = M("character_selector");
local charcreator = M("charcreator");
local User = M("user");
local utils = M("utils");
local skin = M("skin");
local logger = M("core").logger;
local Character = M("character");
local core = M("core");

--[[
Citizen.CreateThread(function()
	while true do
		print(json.encode(GetEntityCoords(PlayerPedId())));
		Citizen.Wait(1000);
	end
end);
]]

local SpawnWithCharacter = function(character)
	local player = PlayerId();
	local playerPed = PlayerPedId();

	--print("giving player control 2");
    SetPlayerControl(player, true);

	--print("unfreezing player 2");
	FreezeEntityPosition(playerPed, false);

	--print("teleporting to " .. json.encode(position));
	local lastPosition = character:getLastPosition();
	utils.teleport(lastPosition);
	
	SetEntityHeading(playerPed, 0.0);

	local skinData = character:getSkin();
	skin.setValues(skinData);
	--print(skinData);
	--print(json.encode(skinData));

	User:GetSelf():setCurrentCharacterId(character.id);
	--print("Setting current character id ", character.id);
	--print("Spawning " .. character:getName());

	Character.onCharacterSpawned:Invoke(character);
end;


core.onInit:Add(function()
	logger.debug("base", "loaded base");
	Citizen.CreateThread(function()
		while true do
			logger.debug("base", "waiting for network session");
			if NetworkIsSessionStarted() then
				logger.debug("base", "session started");
				if IsScreenFadedOut() then
					DoScreenFadeIn();
				end
	
				ShutdownLoadingScreen();
	
				logger.debug("base", "getting character ids");
				local selfUser = User:GetSelf();
				logger.debug("base", "got selfUser", selfUser);
				local characterIds = selfUser:getCharacterIds();
				logger.debug("base", "got character ids");
				if utils.table.size(characterIds) == 0 then
					logger.debug("base", "opening charcreator");
					charcreator.CreateNewCharacter(function(character)
						SpawnWithCharacter(character);
					end);
				else
					logger.debug("base", "opening charselector");
					characterSelector.StartSelection(function(character)
						SpawnWithCharacter(character);
					end);
				end
	
				return;
			end
			Citizen.Wait(0);
		end
	end);
end);

-- disable wanted level
ClearPlayerWantedLevel(PlayerId());
SetMaxWantedLevel(0);

-- Disable default idle camera
Citizen.CreateThread(function()
	while true do
		InvalidateIdleCam();
		InvalidateVehicleIdleCam();
		Citizen.Wait(15000);
	end
end);