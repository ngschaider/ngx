local event = M("event");
local logger = M("logger");
local streaming = M("streaming");
local user = M("user");
local characterClass = M("character");
local charcreator = M("charcreator");
local utils = M("utils");
local skin = M("skin");

local pool = NativeUI.CreatePool();

local cam = nil;

module.StartSelection = function(cb)
	local player = PlayerId();

	local model = "mp_m_freemode_01";
	streaming.RequestModel(model);
	SetPlayerModel(player, model);
	SetModelAsNoLongerNeeded(model);
	
	local playerPed = PlayerPedId();
	SetPedDefaultComponentVariation(playerPed);
	
	FreezeEntityPosition(playerPed, true);
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
	
	user.getCharacters(function(characters)
		local menu = NativeUI.CreateMenu("Charakterauswahl");
		pool:Add(menu);

		menu.Controls.Back.Enabled = false;

		local charsAdded = 0;
		for k,v in pairs(characters) do
			v.getName(function(name)
				local item = NativeUI.CreateItem(name, "Mit " .. name .. " einreisen");
				menu:AddItem(item);

				item.Activated = function()
					DoScreenFadeOut(650)
					while not IsScreenFadedOut() do
						Citizen.Wait(0);
					end

					menu:Visible(false);
					DestroyCam(cam, true);
					RenderScriptCams(false);

					cb(v);
				end;

				charsAdded = charsAdded + 1;
			end);
		end
		
		while charsAdded < #characters do
			Citizen.Wait(0);
		end
		
		local createCharacterItem = NativeUI.CreateItem("~b~Charakter erstellen", "");
		menu:AddItem(createCharacterItem);

		createCharacterItem.Activated = function()
			DoScreenFadeOut(650)
			while not IsScreenFadedOut() do
				Citizen.Wait(0);
			end

			menu:Visible(false);
			DestroyCam(cam, true);
			RenderScriptCams(false);

			charcreator.CreateNewCharacter(function()
				module.StartSelection(cb);
			end);
		end;

		menu:Visible(true);
		pool:RefreshIndex();
	end);
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