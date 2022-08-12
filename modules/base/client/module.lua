local event = M("event");
local characterSelector = M("character_selector");
local charcreator = M("charcreator");
local user = M("user");
local utils = M("utils");
local skin = M("skin");

-- Disable default idle camera
Citizen.CreateThread(function()
	while true do
		InvalidateIdleCam();
		InvalidateVehicleIdleCam();
		Wait(15000);
	end
end);

--[[

Citizen.CreateThread(function()
	while true do
		print(json.encode(GetEntityCoords(PlayerPedId())));
		Citizen.Wait(1000);
	end
end)

]]

local SpawnWithCharacter = function(character)
	local playerPed = PlayerPedId();

    SetPlayerControl(PlayerId(), true);
	FreezeEntityPosition(playerPed, false);

	character.getLastPosition(function(position)
		print("teleporting to " .. json.encode(position));
		utils.teleport(position);
	end);
	
	SetEntityHeading(playerPed, 0.0);
	character.getSkin(function(skinData)
		print(skinData);
		print(json.encode(skinData));
		skin.setSkin(skinData);
	end);

	user.setCurrentCharacterId(character.id);

	character.getName(function(name) 
		print("spawning " .. name);
	end)
end;

Citizen.CreateThread(function()
    while true do
		if NetworkIsSessionStarted() then
			if IsScreenFadedOut() then
				DoScreenFadeIn();
			end

			ShutdownLoadingScreen();

			user.getCharacterIds(function(characterIds)
				if utils.table.size(characterIds) == 0 then
					charcreator.CreateNewCharacter(function()
						SpawnWithCharacter(character);
					end);
				else
					characterSelector.StartSelection(function(character)
						SpawnWithCharacter(character);
					end);
				end
			end);

			return;
		end
		Citizen.Wait(100);
    end
end);

-- disable wanted level
ClearPlayerWantedLevel(PlayerId());
SetMaxWantedLevel(0);