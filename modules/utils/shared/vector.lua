module.vector3.new = function(x, y, z)
    local self = {};

    self.x = x;
    self.y = y;
    self.z = z;

    self.magnitude = function()
        return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2) + math.pow(self.z, 2));
    end;

    self.normalized = function()
        local magnitude = self.magnitude();
        return self.copy().div(magnitude);
    end;

    self.div = function(value)
        self.x = self.x / value;
        self.y = self.y / value;
        self.z = self.z / value;
    end;

    self.mul = function(value)
        self.x = self.x * value;
        self.y = self.y * value;
        self.z = self.z * value;
    end;

    self.copy = function()
        return module.vector3.new(self.x, self.y, self.z);
    end;

    return self;
end;

module.vector3.fromRotation = function(rotation)
end;