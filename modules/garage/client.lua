run("client/class.lua");

Citizen.CreateThread(function()
    local garages = module.GetAll();

    local playerPed = PlayerPedId();
    local playerPos = GetEntityCoords(playerPed);

    for _,garage in pairs(garages) do
        marker.AddMarker({
            type = marker.TYPES.HorizontalSplitArrowCircle;
            position = garage.position,
            scale = vector3(2.0, 2.0, 2.0),
        });
    end
end)