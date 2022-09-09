local glm = require("glm");
local class = M("class");
local core = M("core");

local Area = class("Area", core.SyncObject);
core.RegisterSyncClass(Area);

function Area:initialize(id)
    core.SyncObject.initialize("Area", id, "areas");

    self:syncProperty("points", true, true);
end

function Area:getPoints()
    return json_decode(self:getData("points"));
end

function Area:setPoints(points)
    self:setData("points", json_encode(points));
end

function Area:isPointInside(point)
    local polygon = glm.polygon.new(self:getPoints());
    return polygon.contains(point);
end

module.GetById = function(id)
    return core.GetSyncObject("Area", id);
end