local MOD_TYPES = {
    spoiler = 0,
	frontBumper = 1,
	rearBumper = 2,
	skirt = 3,
	exhaust = 4,
	chassis = 5,
	grill = 6,
	hood = 7,
	leftWing = 8,
	rightWing = 9,
	roof = 10,
	engine = 11,
	brakes = 12,
	gearbox = 13,
	horn = 14,
	suspension = 15,
	armor = 16,
	--NITROUS = 17,
	--TURBO = 18, -- is handled via IsToggleModOn
	--SUBWOOFER = 19,
	--TYRE_SMOKE = 20, -- is handled via IsToggleModOn
	--HYDRAULICS = 21,
	--XENON_LIGHTS = 22, -- is handled via IsToggleModOn
	wheels = 23,
	rearWheels = 24,
	plateHolder = 25,
	vanityPlate = 26,
	trimA = 27,
	ornaments = 28,
	dashboard = 29,
	dial = 30,
	doorSpeaker = 31,
	seats = 32,
	steeringWheel = 33,
	shifterLevers = 34,
	aPlate = 35,
	speakers = 36,
	trunk = 37,
	hydro = 38,
	engineBlock = 39,
	airFilter = 40,
	struts = 41,
	archCover = 42,
	aerials = 43,
	trimB = 44,
	tank = 45,
	--DOOR_L = 46,
	doorR = 47,
	--LIVERY = 48, -- this is handled separately
	lightbar = 49,
}

module.vehicle = module.vehicle or {};

module.vehicle.SetProperties = function(vehicle, properties)
	if not DoesEntityExist(vehicle) then
		return;
	end

	SetVehicleModKit(vehicle, 0);

	if properties.plateIndex then
		SetVehicleNumberPlateTextIndex(vehicle, properties.plateIndex);
	end
	if properties.bodyHealth then
		SetVehicleBodyHealth(vehicle, properties.bodyHealth);
	end
	if properties.engineHealth then
		SetVehicleEngineHealth(vehicle, properties.engineHealth);
	end
	if properties.tankHealth then
		SetVehiclePetrolTankHealth(vehicle, properties.tankHealth);
	end
	if properties.fuelLevel then
		SetVehicleFuelLevel(vehicle, properties.fuelLevel);
	end
	if properties.dirtLevel then
		SetVehicleDirtLevel(vehicle, properties.dirtLevel);
	end
	if properties.customPrimaryColor then
		SetVehicleCustomPrimaryColour(vehicle, properties.customPrimaryColor.r, properties.customPrimaryColor.g, properties.customPrimaryColor.b);
	end
	if properties.customSecondaryColor then
		SetVehicleCustomSecondaryColour(vehicle, properties.customSecondaryColor.r, properties.customSecondaryColor.g, properties.customSecondaryColor.b);
	end

	local primaryColor, secondaryColor = GetVehicleColours(vehicle);
	if properties.primaryColor then
        primaryColor = properties.primaryColor;
	end
	if properties.secondaryColor then
		secondaryColor = properties.secondaryColor;
	end
	SetVehicleColours(vehicle, primaryColor, secondaryColor);

	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle);
	if properties.pearlescentColor then
		pearlescentColor = properties.pearlescentColor;
		
	end
	if properties.wheelColor then
		wheelColor = properties.wheelColor;
	end
	SetVehicleExtraColours(vehicle, pearlescentColor, wheelColor);

	if properties.wheels then
		SetVehicleWheelType(vehicle, properties.wheels)
	end
	if properties.windowTint then
		SetVehicleWindowTint(vehicle, properties.windowTint)
	end

	if properties.neonEnabled then
		SetVehicleNeonLightEnabled(vehicle, 0, properties.neonEnabled[1]);
		SetVehicleNeonLightEnabled(vehicle, 1, properties.neonEnabled[2]);
		SetVehicleNeonLightEnabled(vehicle, 2, properties.neonEnabled[3]);
		SetVehicleNeonLightEnabled(vehicle, 3, properties.neonEnabled[4]);
	end

	if properties.extras then
		for id, enabled in pairs(properties.extras) do
			if enabled then
				SetVehicleExtra(vehicle, id, 0);
			else
				SetVehicleExtra(vehicle, id, 1);
			end
		end
	end

	if properties.neonColor then
		SetVehicleNeonLightsColour(vehicle, properties.neonColor.r, properties.neonColor.g, properties.neonColor.b);
	end
	if properties.xenonColor then
		SetVehicleXenonLightsColor(vehicle, properties.xenonColor)
	end
	if properties.customXenonColor then
		SetVehicleXenonLightsCustomColor(vehicle, properties.customXenonColor.r, properties.customXenonColor.g, properties.customXenonColor.b);
	end

	for k,v in pairs(MOD_TYPES) do
		ToggleVehicleMod(vehicle, v, properties.mods[k]);
	end

	if properties.turbo then
		ToggleVehicleMod(vehicle, 18, properties.turbo);
	end
	if properties.smokeEnabled then
		ToggleVehicleMod(vehicle, 20, properties.smokeEnabled);
	end
	if properties.xenon then
		ToggleVehicleMod(vehicle, 22, properties.xenon);
	end

	if properties.livery then
		SetVehicleMod(vehicle, 48, properties.livery, false);
		SetVehicleLivery(vehicle, properties.livery);
	end

	if properties.windowsBroken then
		for k, v in pairs(properties.windowsBroken) do
			if v then
				SmashVehicleWindow(vehicle, k);
			end
		end
	end

	if properties.doorsBroken then
		for k, v in pairs(properties.doorsBroken) do
			if v then
				SetVehicleDoorBroken(vehicle, k, true);
			end
		end
	end

	if properties.tireBurst then
		for k, v in pairs(properties.tireBurst) do
			if v then
				SetVehicleTyreBurst(vehicle, k, true, 1000.0);
			end
		end
	end
end

module.vehicle.GetProperties = function(vehicle)
	if not DoesEntityExist(vehicle) then
		return;
	end

	local properties = {};

	properties.plateIndex = GetVehicleNumberPlateTextIndex(vehicle);
	properties.bodyHealth = GetVehicleBodyHealth(vehicle);
	properties.engineHealth = GetVehicleEngineHealth(vehicle);
	properties.tankHealth = GetVehiclePetrolTankHealth(vehicle);
	properties.fuelLevel = GetVehicleFuelLevel(vehicle);
	properties.dirtLevel = GetVehicleDirtLevel(vehicle);

	local primaryColor, secondaryColor = GetVehicleColours(vehicle);
	properties.primaryColor = primaryColor;
	properties.secondaryColor = secondaryColor;

	if GetIsVehiclePrimaryColourCustom(vehicle) then
		local r, g, b = GetVehicleCustomPrimaryColour(vehicle);
		properties.customPrimaryColor = {
			r = r,
			g = g,
			b = b
		};
	end

	if GetIsVehicleSecondaryColourCustom(vehicle) then
		local r, g, b = GetVehicleCustomSecondaryColour(vehicle);
		properties.customSecondaryColor = {
			r = r,
			g = g,
			b = b,
		};
	end

	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle);
	properties.pearlescentColor = pearlescentColor;
	properties.wheelColor = wheelColor;

	properties.wheels = GetVehicleWheelType(vehicle);
	properties.windowTint = GetVehicleWindowTint(vehicle);
	properties.xenonColor = GetVehicleXenonLightsColor(vehicle);

	local xenonColorR, xenonColorG, xenonColorB = table.pack(GetVehicleXenonLightsCustomColor(vehicle));
	if xenonColorR and xenonColorG and xenonColorB then
		properties.customXenonColor = {
			r = xenonColorR,
			g = xenonColorG,
			b = xenonColorB,
		};
	end

	properties.neonEnabled = {
		IsVehicleNeonLightEnabled(vehicle, 0),
		IsVehicleNeonLightEnabled(vehicle, 1),
		IsVehicleNeonLightEnabled(vehicle, 2),
		IsVehicleNeonLightEnabled(vehicle, 3),
	};

	local neonColor = table.pack(GetVehicleNeonLightsColour(vehicle));
	properties.neonColor = {
		r = neonColor[1],
		g = neonColor[2],
		b = neonColor[3],
	};

	properties.extras = {};
	for id = 0, 12 do
		if DoesExtraExist(vehicle, id) then
			properties.extras[tostring(id)] = IsVehicleExtraTurnedOn(vehicle, id);
		end
	end

	local tireSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle));
	properties.tireSmokeColor = {
		r = tireSmokeColor[1],
		g = tireSmokeColor[2],
		b = tireSmokeColor[3],
	};

	properties.doorsBroken = {};
	local numDoors = GetNumberOfVehicleDoors(vehicle);
	if numDoors and numDoors > 0 then
		for id = 0, numDoors do
			if IsVehicleDoorDamaged(vehicle, id) then
				properties.doorsBroken[id] = true;
			else
				properties.doorsBroken[id] = false;
			end
		end
	end

	properties.windowsBroken = {};
	for id = 0, 7 do
		if not IsVehicleWindowIntact(vehicle, id) then
			properties.windowsBroken[id] = true;
		else
			properties.windowsBroken[id] = false;
		end
	end

	local tiresIndex = { -- Wheel index list according to the number of vehicle wheels.
		['2'] = {0, 4}, -- Bike and cycle.
		['3'] = {0, 1, 4, 5}, -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
		['4'] = {0, 1, 4, 5}, -- Vehicle with 4 wheels.
		['6'] = {0, 1, 2, 3, 4, 5} -- Vehicle with 6 wheels.
	}
	properties.tireBurst = {};
	local numWheels = GetVehicleNumberOfWheels(vehicle);
	if tiresIndex[numWheels] then
		for tire, idx in pairs(tiresIndex[numWheels]) do
			if IsVehicleTyreBurst(vehicle, idx, false) then
				properties.tireBurst[idx] = true;
			else
				properties.tireBurst[idx] = false;
			end
		end
	end

	properties.mods = {};
	for k,v in pairs(MOD_TYPES) do
		properties.mods[k] = GetVehicleMod(vehicle, v);
	end

	properties.mods.turbo = IsToggleModOn(vehicle, 18);
	properties.mods.smokeEnabled = IsToggleModOn(vehicle, 20);
	properties.mods.xenon = IsToggleModOn(vehicle, 22);

	local livery = GetVehicleMod(vehicle, 48);
	if livery == -1 then
		properties.mods.livery = GetVehicleLivery(vehicle);
	else
		properties.mods.livery = livery;
	end

	return properties;
end