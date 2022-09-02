local class = M("class");

local Vec2 = class("Vec2");

function Vec2:initialize(x, y, z)
    self.x = x;
    self.y = y;
    self.z = z;
end

function Vec2:getMagnitudeSquared()
    return self.x * self.x + self.y * self.y;
end

function Vec2:getMagnitude()
    return math.sqrt(self:magnitudeSquared());
end

function Vec2:setMagnitude(magnitude)
    local angle = self:getAngle();
    self.x = magnitude * math.cos(angle);
    self.y = magnitude * math.sin(angle);
end

function Vec2:copy()
    return Vec2:new(self.x, self.y);
end

function Vec2:getAngle()
    return math.atan(self.y, self.x);
end

function Vec2:setAngle(angle)
    local magnitude = self:magnitude();
    self.x = magnitude * math.cos(angle);
    self.y = magnitude * math.sin(angle);
end

function Vec2:toVector2()
    return vector2(self.x, self.y);
end

function Vec2:toVector3()
    return vector3(self.x, self.y, 0);
end

module.Vec2 = Vec2;