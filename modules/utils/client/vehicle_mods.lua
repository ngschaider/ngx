local modTypes = {
    SPOILER = 0,
	BUMPER_F = 1,
	BUMPER_R = 2,
	SKIRT = 3,
	EXHAUST = 4,
	CHASSIS = 5,
	GRILL = 6,
	BONNET = 7,
	WING_L = 8,
	WING_R = 9,
	ROOF = 10,
	ENGINE = 11,
	BRAKES = 12,
	GEARBOX = 13,
	HORN = 14,
	SUSPENSION = 15,
	ARMOUR = 16,
	NITROUS = 17,
	TURBO = 18,
	SUBWOOFER = 19,
	TYRE_SMOKE = 20,
	HYDRAULICS = 21,
	XENON_LIGHTS = 22,
	WHEELS = 23,
	WHEELS_REAR_OR_HYDRAULICS = 24,
	PLTHOLDER = 25,
	PLTVANITY = 26,
	INTERIOR1 = 27,
	INTERIOR2 = 28,
	INTERIOR3 = 29,
	INTERIOR4 = 30,
	INTERIOR5 = 31,
	SEATS = 32,
	STEERING = 33,
	KNOB = 34,
	PLAQUE = 35,
	ICE = 36,
	TRUNK = 37,
	HYDRO = 38,
	ENGINEBAY1 = 39,
	ENGINEBAY2 = 40,
	ENGINEBAY3 = 41,
	CHASSIS2 = 42,
	CHASSIS3 = 43,
	CHASSIS4 = 44,
	CHASSIS5 = 45,
	DOOR_L = 46,
	DOOR_R = 47,
	LIVERY_MOD = 48,
	LIGHTBAR = 49,
}

module.vehicle = module.vehicle or {};

module.vehicle.GetMods = function(vehicle)
    local mods = {};
    for name,id in pairs(modTypes) do
        mods[name] = GetVehicleMod(vehicle, id);
    end
    return mods;
end

module.vehicle.SetMods = function(vehicle, mods)
    for name,value in pairs(mods) do
        local id = modTypes[name];
        SetVehicleMod(vehicle, id, value); -- TODO: Set custom tires
    end
end