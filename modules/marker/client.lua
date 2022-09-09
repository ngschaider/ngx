local class = M("class");
local logger = M("core").logger;
local Color = M("core").Color;
local Event = M("core").Event;

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

    self.onEnter = Event:new();
    self.onExit = Event:new();
    self.onTickWhileInside = Event:new();
    self.isPlayerInside = false;

    core.onTick:Add(function(data)
        self:tick(data);
    end);
end

function Marker:tick(data)
    local dist = #(data.playerPos - self.position);

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

module.Create = function(...)
    return Marker:new(...);
end