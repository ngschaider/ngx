run("client/config.lua");

local core = M("core");
local net = M("core").net;
local utils = M("utils");
local skin = M("skin");
local User = M("user");
local streaming = M("streaming")
local UI = M("UI");

local cam = nil;

local heading = nil; -- this gets overriden by the loop controlling the camera rotation
local camOffset = nil;
local zoomOffset = nil;

local intensityOptions = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0};

-- firstname, lastname, dateofbirth
local data = {};

module.CreateNewCharacter = function(cb)
    local playerId = PlayerId();
    local ped = PlayerPedId();

    local model = "mp_m_freemode_01";
	streaming.RequestModel(model);
	SetPlayerModel(playerId, model);
    playerId = PlayerPedId(); -- SetPlayerModel changes the ped handle!!!!!
	SetModelAsNoLongerNeeded(model);

    --print("module.CreateNewCharacter", "ped", ped, PlayerPedId());
	SetPedDefaultComponentVariation(ped);

    logger.debug("charcreator", "freezing ped 1");
	FreezeEntityPosition(ped, true);

    utils.teleport({x = -75.015, y = -818.215, z = 325.0});
    SetEntityHeading(playerPed, 0.0);

	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true);
    SetCamRot(cam, 0.0, 0.0, 0.0, true);
    SetCamValues(0.0, 0.7, 1.0);
    SetCamActive(cam, true);
    RenderScriptCams(true, false, 0, false, false);

    DoScreenFadeIn(650);

    local menu = UI.CreateMenu("Dein Charakter");
    pool:Clear();
    pool:Add(menu);
	
	menu.Controls.Back.enabled = false;
	
	local firstnameItem = UI.CreateItem("Vorname", "");
	menu:AddItem(firstnameItem);

    firstnameItem.Activated = function()
        local firstname = utils.textPrompt("Vorname", data.firstname);
        if firstname then
            firstnameItem:RightLabel(firstname);
            data.firstname = firstname;
        end
    end;
	
	local lastnameItem = UI.CreateItem("Nachname", "");
	menu:AddItem(lastnameItem);

    lastnameItem.Activated = function()
        local lastname = utils.textPrompt("Vorname", data.lastname);
        if lastname then
            lastnameItem:RightLabel(lastname);
            data.lastname = lastname;
        end
    end;

    local dateofbirthItem = UI.CreateItem("Geburtstag", "");
    menu:AddItem(dateofbirthItem);

    dateofbirthItem.Activated = function()
        local dateofbirth = utils.textPrompt("Geburtstag", data.dateofbirth);
        if dateofbirth and utils.date.isValid(dateofbirth) then
            dateofbirthItem:RightLabel(dateofbirth);
            data.dateofbirth = dateofbirth;
        end
    end;

    local genderOptions = {"Männlich", "Weiblich"};
    local genderItem = UI.CreateListItem("Geschlecht", genderOptions, 1);
    menu:AddItem(genderItem);

	-- START SUBMENU parents
    local parentsMenu = pool:AddSubMenu(menu, "Eltern");
    menu.Items[#menu.Items]:SetLeftBadge(BadgeStyle.Heart)
    menu.Items[#menu.Items]:RightLabel("~b~→→→")
	
    local heritageWindow = UI.CreateHeritageWindow()
    parentsMenu:AddWindow(heritageWindow)

    local motherItem = UI.CreateListItem("Mutter", Config.motherNames, 1);
    parentsMenu:AddItem(motherItem);

    local fatherItem = UI.CreateListItem("Vater", Config.fatherNames, 1);
    parentsMenu:AddItem(fatherItem);

    local similarityItem = UI.CreateSliderItem("Gesichtstyp", intensityOptions, math.ceil(#intensityOptions * 0.5));
    parentsMenu:AddItem(similarityItem)

    local complexionItem = UI.CreateSliderItem("Hauttyp", intensityOptions, math.ceil(#intensityOptions * 0.5));
    parentsMenu:AddItem(complexionItem)

    parentsMenu.OnListChange = function(sender, item, index)
        if item == motherItem then
            heritageWindow:Index(index, nil);
			skin.setValue("mom", index);
        elseif item == fatherItem then
            heritageWindow:Index(nil, index);
			skin.setValue("dad", index);
        end

        SetCamValues(nil, 0.7, 0.6);
    end

    parentsMenu.OnSliderChange = function(sender, item, index)
		local value = item:IndexToItem(index);
		
        if item == similarityItem then
            skin.setValue("face_weight", value);
        elseif item == complexionItem then
            skin.setValue("skin_weight", value);
        end

        zoomOffset = 0.6
        camOffset = 0.7
    end

	-- END SUBMENU parents
    
	-- START SUBMENU advanced_face
    local advancedFaceMenu = pool:AddSubMenu(menu, "Erweiterte Gesichtsoptionen")
    menu.Items[#menu.Items]:RightLabel("~b~→→→")

    for k, v in pairs(Config.AdvancedFaceParts) do
        local advancedFaceItem = UI.CreateListItem(v.label, intensityOptions, math.ceil(#intensityOptions * 0.5))
        advancedFaceMenu:AddItem(advancedFaceItem);

        advancedFaceItem.OnListChanged = function(menu, item, index)
            --print("setting", v.type, intensityOptions[index]);
            skin.setValue(v.type, intensityOptions[index]);
		    SetCamValues(nil, 0.7, 0.6);
        end;
    end
	-- END SUBMENU advanced_face

    local ageingItem = UI.CreateListItem("Alterung", Config.ageing, 1);
    menu:AddItem(ageingItem);

    local ageingIntensityItem = UI.CreateListItem("Alterungsstärke", intensityOptions, 1);
    menu:AddItem(ageingIntensityItem);

    local eyeColorItem = UI.CreateListItem("Augenfarbe", Config.eyeColors, 1);
    menu:AddItem(eyeColorItem);

    local eyebrowsItem = UI.CreateListItem("Augenbrauen", Config.eyebrows, 1);
    menu:AddItem(eyebrowsItem);

    local eyebrowsIntensityItem = UI.CreateListItem("Augenbrauenstärke", intensityOptions, 1);
    menu:AddItem(eyebrowsIntensityItem);

    local complexionItem = UI.CreateListItem("Schönheitsfehler", Config.complexion, 1);
    menu:AddItem(complexionItem);

    local complexionIntensityItem = UI.CreateListItem("Schönheitsfehler Intensität", intensityOptions, 1);
    menu:AddItem(complexionIntensityItem);

    local sunDamageItem = UI.CreateListItem("Sommersprossen", Config.sundamage, 1);
    menu:AddItem(sunDamageItem);

    local sunDamageIntensityItem = UI.CreateListItem("Sommersprossen Intensität", intensityOptions, 1)
    menu:AddItem(sunDamageIntensityItem)

	local saveItem = UI.CreateItem("~b~Speichern", "");
	menu:AddItem(saveItem);
	
	saveItem.Activated = function(sender, item)
        if not data.firstname or not data.lastname or not data.dateofbirth then
            return;
        end

        --print("hiding menu");
		menu:Visible(false);

        --print("creating character");
        local skinData = skin.getValues();
        local selfUser = User:GetSelf();
        local character = selfUser:createCharacter(data.firstname, data.lastname, data.dateofbirth, skinData);
        --print("destroying cam");
        DestroyCam(cam, true);
        RenderScriptCams(false);
        cb(character);
	end;
	
    menu.OnListChange = function(sender, item, index)
        if item == genderItem then
            skin.setValue("sex", index - 1)
			SetCamValues(nil, 0.2, 1.5);
        elseif item == eyeColorItem then
            skin.setValue("eye_color", index - 1)
			SetCamValues(nil, 0.7, 0.6);
        elseif item == ageingItem then
            --print("setting " .. (index - 1));
            skin.setValue("age", index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == ageingIntensityItem then
            skin.setValue("age_opacity", intensityOptions[index])
            SetCamValues(nil, 0.7, 0.6);
        elseif item == complexionItem then
            skin.setValue("complexion", index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == complexionIntensityItem then
            skin.setValue("complexion_opacity", intensityOptions[index])
            SetCamValues(nil, 0.7, 0.6);
        elseif item == sunDamageItem then
            skin.setValue("sun_damage", index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == sunDamageIntensityItem then
            skin.setValue("sun_damage_opacity", intensityOptions[index])
            SetCamValues(nil, 0.7, 0.6);
        elseif item == eyebrowsItem then
            skin.setValue("eyebrows", index - 1)
            SetCamValues(nil, 0.7, 0.6);
        elseif item == eyebrowsIntensityItem then
            skin.setValue("eyebrows_opacity", intensityOptions[index])
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

--[[
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
]]	

core.onTick:Add(function()
    local angle = -90;

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
end)

net.on("net:resourceStop", function()
    if cam then
        DestroyCam(cam, true);
    end
end)