local class = M("class");

local Vec3 = class("Vec3");

function Vec3:initialize(x, y, z)
    self.x = x;
    self.y = y;
    self.z = z;
end

function Vec3:getMagnitudeSquared()
    return self.x * self.x + self.y * self.y;
end

function Vec3:getMagnitude()
    return math.sqrt(self:magnitudeSquared());
end

function Vec3:setMagnitude(magnitude)
    local angle = self:getAngle();
    self.x = magnitude * math.cos(angle);
    self.y = magnitude * math.sin(angle);
end

function Vec3:copy()
    return Vec3:new(self.x, self.y, self.z);
end

function Vec3:getAngle()
    return math.atan(self.y, self.x);
end

function Vec3:setAngle(angle)
    local magnitude = self:magnitude();
    self.x = magnitude * math.cos(angle);
    self.y = magnitude * math.sin(angle);
end

module.Vec3 = Vec3;