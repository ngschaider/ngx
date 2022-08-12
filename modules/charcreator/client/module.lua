run("client/config.lua");

local logger = M("logger");
local event = M("event");
local callback = M("callback");
local utils = M("utils");
local skin = M("skin");
local user = M("user");
local streaming = M("streaming")

local pool = NativeUI.CreatePool();

local cam = nil

local heading = nil; -- this gets overriden by the loop controlling the camera rotation
local camOffset = nil;
local zoomOffset = nil;

local intensityOptions = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0};

-- firstname, lastname, dateofbirth, height
local data = {};

Citizen.CreateThread(function()
    while true do
        pool:ProcessMenus();
        Citizen.Wait(0);
    end
end)

module.CreateNewCharacter = function(cb)
    local ped = PlayerPedId();

    local model = "mp_m_freemode_01";
	streaming.RequestModel(model);
	SetPlayerModel(player, model);
	SetModelAsNoLongerNeeded(model);

	SetPedDefaultComponentVariation(ped);

	FreezeEntityPosition(ped, true);

    utils.teleport({x = -75.015, y = -818.215, z = 325.0});
    --SetEntityHeading(playerPed, 0.0);
    
	SetEntityRotation(ped, 0.0, 0.0, 180.0, 1);

	cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true);
    --SetCamRot(cam, 0.0, 0.0, 0.0, true);
    SetCamValues(0.0, 0.7, 1.0);
    SetCamActive(cam, true);
    RenderScriptCams(true, false, 0, false, false);

    DoScreenFadeIn(650);

    local menu = NativeUI.CreateMenu("Dein Charakter");
    pool:Clear();
    pool:Add(menu);
	
	menu.Controls.Back.Enabled = false;
	
	local firstnameItem = NativeUI.CreateItem("Vorname", "");
	menu:AddItem(firstnameItem);

    firstnameItem.Activated = function()
        local firstname = utils.textPrompt("Vorname", data.firstname);
        if firstname then
            firstnameItem:RightLabel(firstname);
            data.firstname = firstname;
        end
    end;
	
	local lastnameItem = NativeUI.CreateItem("Nachname", "");
	menu:AddItem(lastnameItem);

    lastnameItem.Activated = function()
        local lastname = utils.textPrompt("Vorname", data.lastname);
        if lastname then
            lastnameItem:RightLabel(lastname);
            data.lastname = lastname;
        end
    end;

    local dateofbirthItem = NativeUI.CreateItem("Geburtstag", "");
    menu:AddItem(dateofbirthItem);

    dateofbirthItem.Activated = function()
        local dateofbirth = utils.textPrompt("Geburtstag", data.dateofbirth);
        if dateofbirth and utils.date.isValid(dateofbirth) then
            dateofbirthItem:RightLabel(dateofbirth);
            data.dateofbirth = dateofbirth;
        end
    end;


    local heightItem = NativeUI.CreateItem("Größe (cm)", "");
    menu:AddItem(heightItem);
    heightItem.Activated = function()
        local height = utils.textPrompt("Größe (cm)", data.height);
        height = tonumber(height);
        if height then
            heightItem:RightLabel(height);
            data.height = height;
        end
    end;

    local genderOptions = {"Männlich", "Weiblich"};
    local genderItem = NativeUI.CreateListItem("Geschlecht", genderOptions, 1);
    menu:AddItem(genderItem);

	-- START SUBMENU parents
    local parentsMenu = pool:AddSubMenu(menu, "Eltern");
    menu.Items[#menu.Items]:SetLeftBadge(BadgeStyle.Heart)
    menu.Items[#menu.Items]:RightLabel('~b~→→→')
	
    local heritageWindow = NativeUI.CreateHeritageWindow()
    parentsMenu:AddWindow(heritageWindow)

    local motherItem = NativeUI.CreateListItem("Mutter", Config.motherNames, 1);
    parentsMenu:AddItem(motherItem);

    local fatherItem = NativeUI.CreateListItem("Vater", Config.fatherNames, 1);
    parentsMenu:AddItem(fatherItem);

    local similarityItem = NativeUI.CreateSliderItem("Gesichtstyp", intensityOptions, math.ceil(#intensityOptions * 0.5));
    parentsMenu:AddItem(similarityItem)

    local complexionItem = NativeUI.CreateSliderItem("Hauttyp", intensityOptions, math.ceil(#intensityOptions * 0.5));
    parentsMenu:AddItem(complexionItem)

    parentsMenu.OnListChange = function(sender, item, index)
        if item == motherItem then
            heritageWindow:Index(index, nil);
			skin.change('mom', index);
        elseif item == fatherItem then
            heritageWindow:Index(nil, index);
			skin.change('dad', index);
        end

        SetCamValues(nil, 0.7, 0.6);
    end

    parentsMenu.OnSliderChange = function(sender, item, index)
		local value = item:IndexToItem(index);
		
        if item == similarityItem then
            skin.change("face_md_weight", value);
        elseif item == complexionItem then
            skin.change("skin_md_weight", value);
        end

        zoomOffset = 0.6
        camOffset = 0.7
    end

	-- END SUBMENU parents
    
	-- START SUBMENU advanced_face
    local advancedFaceMenu = pool:AddSubMenu(menu, "Erweiterte Gesichtsoptionen")
    menu.Items[#menu.Items]:RightLabel('~b~→→→')

    for k, v in pairs(Config.AdvancedFaceParts) do
        local advancedFaceItem = NativeUI.CreateListItem(v.label, intensityOptions, math.ceil(#intensityOptions * 0.5))
        advancedFaceMenu:AddItem(advancedFaceItem);

        advancedFaceItem.OnListChanged = function(menu, item, index)
            skin.change(v.type, index - 1);
		    SetCamValues(nil, 0.7, 0.6);
        end;
    end
	-- END SUBMENU advanced_face

    local ageingItem = NativeUI.CreateListItem("Alterung", Config.ageing, 1);
    menu:AddItem(ageingItem);

    local ageingIntensityItem = NativeUI.CreateListItem("Alterungsstärke", intensityOptions, 1);
    menu:AddItem(ageingIntensityItem);

    local eyeColourItem = NativeUI.CreateListItem("Augenfarbe", Config.eyeColors, 1);
    menu:AddItem(eyeColourItem);

    local eyebrowsItem = NativeUI.CreateListItem("Augenbrauen", Config.eyebrows, 1);
    menu:AddItem(eyebrowsItem);

    local eyebrowsIntensityItem = NativeUI.CreateListItem("Augenbrauenstärke", intensityOptions, 1);
    menu:AddItem(eyebrowsIntensityItem);

    local complexionItem = NativeUI.CreateListItem("Teint", Config.complexion, 1);
    menu:AddItem(complexionItem);

    local complexionIntensityItem = NativeUI.CreateListItem("Teint Intensität", intensityOptions, 1);
    menu:AddItem(complexionIntensityItem);

    local sunDamageItem = NativeUI.CreateListItem("Sommersprossen", Config.sundamage, 1);
    menu:AddItem(sunDamageItem);

    local sunDamageIntensityItem = NativeUI.CreateListItem("Sommersprossen Intensität", intensityOptions, 1)
    menu:AddItem(sunDamageIntensityItem)

	local saveItem = NativeUI.CreateItem("~b~Speichern", "");
	menu:AddItem(saveItem);
	
	saveItem.Activated = function(sender, item)
        if not data.firstname or not data.lastname or not data.dateofbirth or not data.height then
            return;
        end

        print("hiding menu");
		menu:Visible(false);

        print("creating character");
        local skinData = skin.getSkin();
        user.createCharacter(data.firstname, data.lastname, data.dateofbirth, data.height, skinData, function(character)
            print("destroying cam");
            DestroyCam(cam, true);
            cb(character);
        end);
	end;
	
    menu.OnListChange = function(sender, item, index)
        if item == genderItem then
            skin.change('sex', index - 1)
			SetCamValues(nil, 0.2, 1.5);
        elseif item == eyeColourItem then
            skin.change('eye_color', index - 1)
			SetCamValues(nil, 0.7, 0.6);
        elseif item == ageingItem then
            skin.change('age_1', index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == ageingIntensityItem then
            skin.change('age_2', index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == complexionItem then
            skin.change('complexion_1', index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == complexionIntensityItem then
            skin.change('complexion_2', index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == sunDamageItem then
            skin.change('sun_1', index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == sunDamageIntensityItem then
            skin.change('sun_2', index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == eyebrowsItem then
            skin.change('eyebrows_1', index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == eyebrowsIntensityItem then
            skin.change('eyebrows_2', index - 1)
            SetCamValues(nil, 0.7, 0.6);
        end
    end

    menu:Visible(true);
    pool:RefreshIndex();
	pool:MouseEdgeEnabled(false);
end;

function SetCamValues(heading2, camOffset2, zoomOffset2)
    if heading2 then
        heading = heading2;
    end
    if camOffset2 then
        camOffset = camOffset2;
    end
    if zoomOffset2 then
        zoomOffset = zoomOffset2;
    end

	if not cam then
		return;
	end
	
	local ped = PlayerPedId();
	local pedCoords = GetEntityCoords(ped);

	local angle = heading * math.pi / 180.0 -- convert heading to radians to work with trig. functions

	-- get a normalized vector pointing into the direction of "angle"
	local theta = {
		x = math.cos(angle),
		y = math.sin(angle)
	}
	
	-- take coords and move "zoomOffset" units into the direction of "theta"
	local pos = {
		x = pedCoords.x + (zoomOffset * theta.x),
		y = pedCoords.y + (zoomOffset * theta.y),
	}
	
	--[[local angleToLook = heading - 140.0;
	if angleToLook > 360 then
		angleToLook = angleToLook - 360;
	elseif angleToLook < 0 then
		angleToLook = angleToLook + 360;
	end
	
    -- convert to radians to work with trig. functions
	angleToLook = angleToLook * math.pi / 180.0; 
    
	
	-- get a normalized vector pointing into the direction of "angleToLook"
	local thetaToLook = {
		x = math.cos(angleToLook),
		y = math.sin(angleToLook)
	};
	
	-- take coords and move "zoomOffset" units into the direction of "thetaToLook"
	--[[local posToLook = {
		x = coords.x + (zoomOffset * thetaToLook.x),
		y = coords.y + (zoomOffset * thetaToLook.y),
	};]]

	-- set position and rotation (shift z coordinate by "camOffset")
	SetCamCoord(cam, pos.x, pos.y, pedCoords.z + camOffset)
	PointCamAtCoord(cam, pedCoords.x, pedCoords.y, pedCoords.z + camOffset)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if cam ~= nil then
            DisableControlAction(2, 30, true) -- D (INPUT_MOVE_LR)
            DisableControlAction(2, 31, true) -- S (INPUT_MOVE_UD)
            DisableControlAction(2, 32, true) -- W (INPUT_MOVE_UP_ONLY)
            DisableControlAction(2, 33, true) -- S (INPUT_MOVE_DOWN_ONLY)
            DisableControlAction(2, 34, true) -- A (INPUT_MOVE_LEFT_ONLY)
            DisableControlAction(2, 35, true) -- D (INPUT_MOVE_LEFT_ONLY)
			
            DisableControlAction(0, 24,   true) -- Right Mouse Button (INPUT_AIM)
			DisableControlAction(0, 25,   true) -- Left Mouse Button (INPUT_ATTACK)
		end
	end
end)
	
Citizen.CreateThread(function()
	local angle = -90;

	while true do
		Citizen.Wait(0)

		if cam ~= nil then
            if IsDisabledControlPressed(0, 108) then -- NUMPAD 4
                angle = angle - 1
            elseif IsDisabledControlPressed(0, 109) then -- NUMPAD 6
                angle = angle + 1
            end

            if angle > 360 then
                angle = angle - 360
            elseif angle < 0 then
                angle = angle + 360
            end

            SetCamValues(angle, nil, nil);
		end
	end
end)

event.on("event:resourceStop", function()
    if cam then
        DestroyCam(cam, true);
    end
end)