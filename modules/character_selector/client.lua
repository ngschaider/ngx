local event = M("event");
local streaming = M("streaming");
local User = M("user");
local charcreator = M("charcreator");
local utils = M("utils");
local skin = M("skin");
local UI = M("UI");

local pool = UI.CreatePool();

local cam = nil;

module.StartSelection = function(cb)
	local player = PlayerId();

	local model = "mp_m_freemode_01";
	streaming.RequestModel(model);
	SetPlayerModel(player, model);
	SetModelAsNoLongerNeeded(model);
	
	local playerPed = PlayerPedId();
	SetPedDefaultComponentVariation(playerPed);
	
	--print("freezing player 3");
	FreezeEntityPosition(playerPed, true);

	--print("taking player control 3");
	SetPlayerControl(player, false);

	local pos = {
		x = 402.86, 
		y = -996.74, 
		z = -100.0, 
	};

	SetEntityRotation(playerPed, 0.0, 0.0, 180.0, 1);
	utils.teleport(pos);

	ClearPedTasksImmediately(playerPed);
	
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA");
	SetCamFov(cam, 70.0);
	SetCamCoord(cam, 402.99, -999.01, -98.0);
    PointCamAtCoord(cam, pos.x, pos.y, pos.z + 1.0);
	SetCamActive(cam, true);
	RenderScriptCams(true);
	
	local selfUser = User:GetSelf();
	local characters = selfUser:getCharacters();
	local menu = UI.CreateMenu("Charakterauswahl");
	pool:Add(menu);

	menu.Controls.Back.enabled = false;

	for _,character in pairs(characters) do
		local characterName = character:getName();
		local item = UI.CreateItem(characterName, "Mit " .. characterName .. " einreisen");
		menu:AddItem(item);

		item.Activated = function()
			DoScreenFadeOut(650)
			while not IsScreenFadedOut() do
				Citizen.Wait(0);
			end

			menu:Visible(false);
			DestroyCam(cam, true);
			RenderScriptCams(false);
			
			cb(character);
		end;

		item.OnSelected = function()
			--print("onSelected");
			local skinData = character:getSkin();
			print("111", json.encode(skinData));
			skin.setValues(skinData);
		end;
	end
	
	local createCharacterItem = UI.CreateItem("~b~Charakter erstellen", "");
	menu:AddItem(createCharacterItem);

	createCharacterItem.Activated = function()
		DoScreenFadeOut(650)
		while not IsScreenFadedOut() do
			Citizen.Wait(0);
		end

		menu:Visible(false);
		DestroyCam(cam, true);
		RenderScriptCams(false);

		charcreator.CreateNewCharacter(function(character)
			module.StartSelection(function(character)
				cb(character);
			end);
		end);
	end;

	menu:Visible(true);
	pool:RefreshIndex();
end;

Citizen.CreateThread(function()
	while true do
		if pool then
        	pool:ProcessMenus();
		end
		Citizen.Wait(0);
	end
end)

event.on("event:resourceStop", function()
  if cam then
	DestroyCam(cam, true);
  end
end)