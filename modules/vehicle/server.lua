local class = M("class");
local Character = M("character");

local Vehicle = class("Vehicle", core.SyncObject);
core.RegisterSyncClass(Vehicle);

function Vehicle:initialize(id)
    core.SyncObject.initialize(self, "Vehicle", id, "vehicles");

    self:syncProperty("plate", true, false);
    self:syncProperty("model", true, false);
    self:rpcMethod("getDeformations", true);
    self:syncProperty("ownerType", true, false);
    self:syncProperty("ownerId", true, false);
    self:syncProperty("garageId", true, false);
end

function Vehicle:getId()
    return self:getData("id");
end

function Vehicle:getPlate()
    return self:getData("plate");
end

function Vehicle:getModel()
    return self:getData("model");
end

function Vehicle:getDeformations()
    local deformationsStr = self:getData("deformations");
    return json.decode(deformationsStr);
end

function Vehicle:getOwnerType()
    return self:getData("ownerType");
end

function Vehicle:getOwnerId()
    return self:getData("ownerId");
end

function Vehicle:getGarageId()
    return self:getData("garageId");
end

function Vehicle:getGarage()
    local id = self:getGarageId();
    return Garage.GetById(id);
end

function Vehicle:setGarageId(id)
    self:setData("garageId", id);
end

function Vehicle:setGarage(garage)
    self:setGarageId(garage.id);
end

function Vehicle:getNetId()
    self:getData("netId");
end

function Vehicle:setNetId(netId)
    self:setData("netId", netId);
end

function Vehicle:getOwner()
    logger.warn("vehicle", "Vehicle:getOwner", "ownerType,ownerId", ownerType, ownerId);
    local ownerType = self:getOwnerType();
    local ownerId = self:getOwnerId();
    if ownerType == "Character" then
        return Character.GetById(ownerId);
    end

    logger.warn("vehicle", "Vehicle:getOwner could not find a valid owner type for id", ownerId);
    return nil;
end

module.GetById = function(id)
    return core.GetSyncObject("Vehicle", id);
end