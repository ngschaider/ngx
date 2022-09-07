run("client/class.lua");

local Marker = M("marker");
local logger = M("core").logger;

Citizen.CreateThread(function()
    local garages = module.GetAll();

    local playerPed = PlayerPedId();
    local playerPos = GetEntityCoords(playerPed);

    for _,garage in pairs(garages) do
        --logger.debug("garage", "adding garage marker", garage:getPosition());
        local marker = Marker.Create(garage:getPosition());
        marker.scale = vector3(4.0, 4.0, 0.2);
    end
end)