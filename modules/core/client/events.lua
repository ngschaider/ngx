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

module.onInit = Event:new();
Citizen.CreateThread(function()
    Citizen.Wait(200);
    module.onInit:Invoke();
end)

module.onPlayerVehicleEnter = Event:new();
module.onPlayerVehicleExit = Event:new();
module.onPlayerVehicleChange = Event:new();

local lastPlayerVehicle = nil;
module.onTick:Add(function(data)
    if data.playerVehicle ~= lastPlayerVehicle then
        module.onPlayerVehicleChange:Invoke(data.playerVehicle, lastPlayerVehicle);

        if data.playerVehicle then
            module.onPlayerVehicleEnter:Invoke(data.playerVehicle);
        else
            module.onPlayerVehicleExit:Invoke(data.playerVehicle);
        end

        lastPlayerVehicle = data.playerVehicle;
    end
end);