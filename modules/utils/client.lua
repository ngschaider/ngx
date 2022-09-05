local event = M("core").event;

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

	if vehicle ~= 0 then
		FreezeEntityPosition(vehicle, true);
	else
		FreezeEntityPosition(ped, true);
	end

	SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z);

	while not HasCollisionLoadedAroundEntity(ped) do
		RequestCollisionAtCoord(coords.x, coords.y, coords.z);
		Citizen.Wait(0);
	end

	if vehicle ~= 0 then
		FreezeEntityPosition(vehicle, false);
	else
		FreezeEntityPosition(ped, false);
	end

	-- Remove black screen once the teleport is complete.
	DoScreenFadeIn(650);
end;