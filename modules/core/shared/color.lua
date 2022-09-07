local class = M("class");


local Color = class("Color");

function Color:initialize(r, g, b, a)
    self.r = r;
    self.g = g;
    self.b = b;
    self.a = a or 255; -- 255 is fully opaque (non-transparent)
end

module.Color = Color;