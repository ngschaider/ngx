local class = M("class");
local logger = M("core").logger;
local Color = M("core").Color;

local Marker = class("Marker");


local markers = {};

--logger.debug("garage", "loading clientsided");

function Marker:initialize(position)

    self.position = position;
    self.rotation = vector3(0.0, 0.0, 0.0);
    self.direction = vector3(0.0, 0.0, 0.0);
    self.scale = vector3(1.0, 1.0, 1.0);
    self.color = Color:new(100, 255, 0, 100);
    self.type = TYPES.VerticalCylinder;
    self.bobUpAndDown = false;
    self.faceCamera = false;
    self.distance = 10;

    table.insert(markers, self);
end

function Marker:draw()
    DrawMarker(self.type, self.position, self.direction, self.rotation, self.scale, self.color.r, self.color.g, self.color.b, self.color.a, self.bobUpAndDown, self.faceCamera, 2, nil, nil, false);
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId();
        local playerPos = GetEntityCoords(ped);

        --logger.debug("marker", "looping marker");
        for _,marker in pairs(markers) do
            local dist = #(playerPos - marker.position);
            --logger.debug("marker", "dist,marker.distance", dist, marker.distance)

            if dist < marker.distance then
                --logger.debug("marker", "drawing");
                marker:draw();
            end
        end
        Citizen.Wait(0);
    end
end);

module.Create = function(...)
    return Marker:new(...);
end