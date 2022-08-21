local event = M("event");
local notification = M("notification");

module.textPrompt = function(title, placeholder, maxLength)
	if not maxLength then 
		maxLength = 30;
	end

	AddTextEntry("FMMC_KEY_TIP1", title);
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", placeholder, "", "", "", maxLength);

	local result = nil;
	while result ~= 1 and result ~= 2 do
		result = UpdateOnscreenKeyboard();
		Citizen.Wait(0);
	end

	if result ~= 2 then
		local text = GetOnscreenKeyboardResult();
		return tostring(text);
	else
		return nil;
	end
end;

module.teleport = function(coords)
	-- Fade screen to hide how clients get teleported.
	DoScreenFadeOut(650)
	while not IsScreenFadedOut() do
		Citizen.Wait(0);
	end

	local ped = PlayerPedId();
	local vehicle = GetVehiclePedIsIn(ped, false);
	local oldCoords = GetEntityCoords(ped);

	if vehicle ~= 0 then
		--print("freezing vehicle 4");
		FreezeEntityPosition(vehicle, true);
	else
		--print("freezing ped 4");
		FreezeEntityPosition(ped, true);
	end

	--local found = false;
	--local groundZ = coords.z;

	-- teleport player to level 1000 and lower the height until the ground is in render distance
	--[[for z = 1000.0, 0.0, -25.0 do
		SetPedCoordsKeepVehicle(ped, coords.x, coords.y, z);

		while not HasCollisionLoadedAroundEntity(ped) do
			RequestCollisionAtCoord(coords.x, coords.y, z);
			Citizen.Wait(0);
		end
	
		found, groundZ = GetGroundZFor_3dCoord(x, y, z, false);

		if found then
			break;
		end
	end]]

	SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z);

	while not HasCollisionLoadedAroundEntity(ped) do
		RequestCollisionAtCoord(coords.x, coords.y, coords.z);
		Citizen.Wait(0);
	end

	if vehicle ~= 0 then
		--print("unfreezing vehicle 4");
		FreezeEntityPosition(vehicle, false);
	else
		--print("unfreezing ped 4");
		FreezeEntityPosition(ped, false);
	end

	-- Remove black screen once the teleport is complete.
	DoScreenFadeIn(650);
end;
event.onShared("utils:teleport", module.teleport);