Citizen.CreateThread(function()
	while true do
	    SetVehicleDensityMultiplierThisFrame(0.0);
	    SetPedDensityMultiplierThisFrame(0.0);
	    SetRandomVehicleDensityMultiplierThisFrame(0.0);
	    SetParkedVehicleDensityMultiplierThisFrame(0.0);
	    SetScenarioPedDensityMultiplierThisFrame(0.0);

	    Citizen.Wait(0);
	end
end)