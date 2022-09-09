local glm = require("glm");
local class = M("class");
local core = M("core");
local utils = M("utils");

local pointsDrawn = {};
Citizen.CreateThread(function()
    while true do 
        local p1 = nil;
        for _,p2 in pairs(pointsDrawn) do
            if p1 then
                DrawPoly(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, p1.x, p1.y, p2.z + 20);
                DrawPoly(p2.x, p2.y, p2.z, p2.x, p2.y, p2.z + 20, p1.x, p1.y, p1.z + 20);

                p1 = nil;
            else
                p1 = point;
            end
        end
        Citizen.Wait(0);
    end
end);

local Area = class("Area", core.SyncObject);
core.RegisterSyncClass(Area);

function Area:initialize(id)
    core.SyncObject.initialize("Area", id, "areas");
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

function Area:startSelection()
    local points = {};

    while true do
        local point = utils.camera.RaycastGameplayCamera();

        if IsControlJustPressed(0, 51) then -- E
            table.insert(points, point);
            table.insert(pointsDrawn, point);
        end

        if IsControlJustPressed(0, 23) then -- ENTER
            break;
        end

        Citizen.Wait(0);
    end

    pointsDrawn = {};
    self:setPoints(points);
end

module.GetById = function(id)
    return core.GetSyncObject("Area", id);
end