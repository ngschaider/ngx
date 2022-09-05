local event = M("core").event;

local markerId = 0;
local GetMarkerId = function()
    markerId = markerId + 1;
    return markerId;
end

local markers = {};
module.AddMarker = function(type, pos, distance, color, dir, rot, scale, bob, faceCamera, rotate)
    local id = GetMarkerId();

    distance = distance or 20;
    color = color or vector3(100, 255, 0);
    dir = dir or vector3(0.0, 0.0, 0.0);
    rot = rot or vector3(0.0, 0.0, 0.0);
    scale = scale or vector3(1.0, 1.0, 2.0);

    local marker = {
        id = id,
        distance = distance,
        type = type,
        pos = pos,
        dir = dir,
        rot = rot,
        scale = scale,
        color = color,
        bob = bob,
        faceCamera = faceCamera,
        rotate = rotate,
    }
end

module.RemoveMarker = function(id)
    markers[id] = nil;
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId();
        local playerPos = GetEntityCoords(playerPed);
        for _,marker in pairs(markers) do
            if marker.visible then
                local dist = #(marker.pos - playerPos);
                if dist < marker.dist then
                    DrawMarker(marker.type, marker.pos, marker.dir, marker.rot, marker.scale, marker.color, marker.bob, marker.faceCamera, marker.rotate, nil, nil);
                end
            end
        end
        Citizen.Wait(0);
    end
end)

event.on("marker:addMarker", module.AddMarker);
event.on("marker:removeMarker", module.RemoveMarker);