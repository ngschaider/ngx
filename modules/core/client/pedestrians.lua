module.onTick:Add(function(data)
	SetVehicleDensityMultiplierThisFrame(0.0);
	SetPedDensityMultiplierThisFrame(0.0);
	SetRandomVehicleDensityMultiplierThisFrame(0.0);
	SetParkedVehicleDensityMultiplierThisFrame(0.0);
	SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0);
	SetGarbageTrucks(false);
	SetRandomBoats(false);
	SetCreateRandomCops(false);
	SetCreateRandomCopsNotOnScenarios(false);
	SetCreateRandomCopsOnScenarios(false);

	local x,y,z = table.unpack(data.playerPos)
	ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
	RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0);
end);


