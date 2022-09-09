local Event = module.event;

module.onTick = Event:new();

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId();
        local playerPos = GetEntityCoords(playerPed);
        local playerVehicle = GetVehiclePedIsIn(playerPed, false);

        local data = {
            playerPed = playerPed,
            playerPos = playerPos,
            playerVehicle = playerVehicle,
        };

        onTick:Invoke(data);
        Citizen.Wait(0);
    end
end);