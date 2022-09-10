local Event = module.Event;

module.onTick = Event:new();

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId();
        local playerPos = GetEntityCoords(playerPed);
        
        local playerVehicle = GetVehiclePedIsIn(playerPed, false);
        if playerVehicle == 0 then
            playerVehicle = nil;
        end

        local data = {
            playerPed = playerPed,
            playerPos = playerPos,
            playerVehicle = playerVehicle,
        };

        module.onTick:Invoke(data);
        Citizen.Wait(0);
    end
end);