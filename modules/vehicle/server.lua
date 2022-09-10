local class = M("class");
local Character = M("character");
local core = M("core");
local Garage = M("garage");
local logger = M("core").logger;

local Vehicle = class("Vehicle", core.SyncObject);
core.RegisterSyncClass(Vehicle);

function Vehicle:initialize(id)
    core.SyncObject.initialize(self, "Vehicle", id, "vehicles");

    self:syncProperty("plate", true, false);
    self:syncProperty("model", true, false);
    self:syncProperty("positionX", true, false);
    self:syncProperty("positionY", true, false);
    self:syncProperty("positionZ", true, false);
    self:syncProperty("deformations", true, false);
    self:rpcMethod("save", true, false);
    self:syncProperty("ownerType", true, false);
    self:syncProperty("ownerId", true, false);
    self:syncProperty("garageId", true, true);
    self:syncProperty("primaryColor", true, false);
    self:syncProperty("secondaryColor", true, false);
    self:syncProperty("modKit", true, false);
    self:syncProperty("netId", true, true);
    self:syncProperty("mods", true, false);
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

function Vehicle:getPosition()
    return vector3(
        tonumber(self:getData("positionX")),
        tonumber(self:getData("positionY")),
        tonumber(self:getData("positionZ"))
    );
end

function Vehicle:setPosition(vec)
    self:setData("positionX", vec.x);
    self:setData("positionY", vec.y);
    self:setData("positionZ", vec.z);
end

function Vehicle:getPrimaryColor()
    return self:getData("primaryColor");
end

function Vehicle:setPrimaryColor(primaryColor)
    self:setData("primaryColor", primaryColor);
end

function Vehicle:getSecondaryColor()
    return self:getData("secondaryColor");
end

function Vehicle:setSecondaryColor(secondaryColor)
    self:setData("secondaryColor", secondaryColor);
end

function Vehicle:getMods()
    return json.decode(self:getData("mods"));
end

function Vehicle:setMods(mods)
    self:setData("mods", json.encode(mods));
end

function Vehicle:getModKit()
    return self:getData("modKit");
end

function Vehicle:setModKit(modKit)
    return self:setData("modKit", modKit);
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

function Vehicle:save(deformations)
    self:setDeformations(deformations);

    local netId = self:getNetId();
    if netId then
        local veh = NetworkGetEntityFromNetworkId(netId);
        local pos = GetEntityCoords(veh);
        self:setPosition(pos);
    end
end

function Vehicle:getOwner()
    local ownerType = self:getOwnerType();
    local ownerId = self:getOwnerId();
    logger.warn("vehicle", "Vehicle:getOwner", "ownerType,ownerId", ownerType, ownerId);

    if ownerType == "Character" then
        return Character.GetById(ownerId);
    end

    logger.warn("vehicle", "Vehicle:getOwner could not find a valid owner type for id", ownerId);
    return nil;
end

module.GetById = function(id)
    return core.GetSyncObject("Vehicle", id);
end