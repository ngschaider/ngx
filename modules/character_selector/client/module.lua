local event = M("event");
local logger = M("logger");
local streaming = M("streaming");
local user = M("user");
local characterClass = M("character");
local charcreator = M("charcreator");
local utils = M("utils");
local skin = M("skin");

local pool = NativeUI.CreatePool();

event.on("character:construct:after", function(character)
	character.spawn = function()
		character.getLastPosition(function(position)
			utils.teleport(position);
		end);
		SetEntityHeading(ped, 0.0);
		skin.applySkin(character.getSkin());
		event.emit("character:playerSpawned");

		character.getUser().setLastCharacter(v.id);
		character.getUser().setCurrentCharacter(v.id);
	end;
end);

event.on("base:playerJoined", function()	
	local player = PlayerId();

	local model = "mp_m_freemode_01";
	streaming.RequestModel(model);
	SetPlayerModel(player, model);
	SetModelAsNoLongerNeeded(model);
	
	local ped = PlayerPedId();
	SetPedDefaultComponentVariation(ped);
	
	FreezeEntityPosition(ped, true);

	local pos = {
		x = 402.86, 
		y = -996.74, 
		z = -99.0, 
	};

	SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false, true);
	SetEntityRotation(ped, 0.0, 0.0, 180.0, 1);
	
	local time = GetGameTimer();
	RequestCollisionAtCoord(pos.x, pos.y, pos.z);
	while not HasCollisionLoadedAroundEntity(ped) and time + 2000 < GetGameTimer() do
		logger.debug("waiting for collision to load", ped, PlayerPedId());
		Citizen.Wait(0);
	end

	ClearPedTasksImmediately(ped);
	
	SetPlayerControl(player, false);
	FreezeEntityPosition(ped, false);
	
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA");
	SetCamFov(cam, 70.0);
	SetCamCoord(cam, 402.99, -999.01, -98.0);
    PointCamAtCoord(cam, pos.x, pos.y, pos.z);
	SetCamActive(cam, true);
	RenderScriptCams(true);
	
	ShutdownLoadingScreen();
	
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
					menu:Visible(false);
					DestroyCam(cam, true);
					SetPlayerControl(player, true);
					RenderScriptCams(false);
					
					v.spawn();
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
			menu:Visible(false);
			charcreator.CreateNewCharacter();
			DestroyCam(cam, true);
		end;

		menu:Visible(true);
		pool:RefreshIndex();
	end);
end);

Citizen.CreateThread(function()
	while true do
        pool:ProcessMenus();
		Citizen.Wait(0);
	end
end)

event.on("event:resourceStop", function()
  if cam then
	DestroyCam(cam, true);
  end
end)