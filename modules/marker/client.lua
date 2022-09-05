local event = M("core").event;

local markerId = 0;
local GetMarkerId = function()
    markerId = markerId + 1;
    return markerId;
end

local markers = {};
module.AddMarker = function(options)
    assert(options and options.type and options.position)

    options.distance = options.distance or 20;
    options.color = options.color or vector3(100, 255, 0);
    options.direction = options.dir or vector3(0.0, 0.0, 0.0);
    options.rotation = options.rot or vector3(0.0, 0.0, 0.0);
    options.scale = options.scale or vector3(1.0, 1.0, 2.0);
    options.bobUpAndDown = options.bobUpAndDown or false;
    options.faceCamera = options.faceCamera or false;
    options.rotate = options.rotate or false;

    local id = GetMarkerId();

    table.insert(markers, {
        id = id,
        visible = true,
        options = options,
    });
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
                local dist = #(marker.position - playerPos);
                if dist < marker.dist then
                    local o = marker.options;
                    DrawMarker(o.type, o.position, o.direction, o.rotation, o.scale, o.color, o.bobUpAndDown, o.faceCamera, o.rotate, nil, nil);
                end
            end
        end
        Citizen.Wait(0);
    end
end)

event.on("marker:addMarker", module.AddMarker);
event.on("marker:removeMarker", module.RemoveMarker);