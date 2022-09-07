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

    self.onEnter = function() end;
    self.onExit = function() end;
    self.onTickWhileInside = function() end;
    self.isPlayerInside = false;

    table.insert(markers, self);
end

function Marker:tick()
    local ped = PlayerPedId();
    local playerPos = GetEntityCoords(ped);

    local dist = #(playerPos - self.position);

    if dist < self.distance then
        local radius = math.max(math.max(self.scale.x, self.scale.y) * 0.65, 1.2);

        if not self.isPlayerInside and dist < radius then
            self.isPlayerInside = true;
            self.onEnter();
        end

        if self.isPlayerInside and dist > radius then
            self.isPlayerInside = false;
            self.onExit();
        end

        if self.isPlayerInside then
            self.onTickWhileInside();
        end

        DrawMarker(self.type, self.position, self.direction, self.rotation, self.scale, self.color.r, self.color.g, self.color.b, self.color.a, self.bobUpAndDown, self.faceCamera, 2, nil, nil, false);
    end
end

Citizen.CreateThread(function()
    while true do
        --logger.debug("marker", "looping marker");
        for _,marker in pairs(markers) do
            --logger.debug("marker", "dist,marker.distance", dist, marker.distance)
            
            --logger.debug("marker", "tick");
            marker:tick();
        end
        Citizen.Wait(0);
    end
end);

module.Create = function(...)
    return Marker:new(...);
end