local class = M("class");
local core = M("core");

local Vehicle = class("Vehicle", core.SyncObject);
core.RegisterSyncClass(Vehicle);

function Vehicle:initialize(id)
    core.SyncObject.initialize(self, "Vehicle", id, "vehicles");
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

function Vehicle:getPrimaryColor()
    return self:getData("primaryColor");
end

function Vehicle:getSecondaryColor()
    return self:getData("secondaryColor");
end

function Vehicle:getMods()
    return json.decode(self:getData("mods"));
end

function Vehicle:getModKit()
    return self:getData("modKit");
end

function Vehicle:getDeformations()
    return json.decode(self:getData("deformations"));
end

function Vehicle:getGarageId()
    return self:getData("garageId");
end

function Vehicle:getGarage()
    local id = self:getGarageId();
    return Garage.GetById(id);
end

function Vehicle:setGarageId(garageId)
    self:setData("garageId", garageId);
end

function Vehicle:setGarage(garage)
    self:setGarageId(garage.id);
end

function Vehicle:getOwnerType()
    return self:getData("ownerType");
end

function Vehicle:getOwnerId()
    return self:getData("ownerId");
end

function Vehicle:getOwner()
    local ownerType = self:getOwnerType();
    local ownerId = self:getOwnerId();
    if ownerType == "Character" then
        return Character.GetById(ownerId);
    end

    logger.warn("vehicle", "Vehicle:getOwner could not find a valid owner type for id", ownerId);
    return nil;
end

function Vehicle:getNetId()
    return self:getData("netId");
end

function Vehicle:setNetId(netId)
    self:setData("netId", netId);
end

function Vehicle:spawn()
    local garage = self:getGarage();

    local veh = CreateVehicle(self:getModel(), garage:getPosition(), 0.0, true, true);
    local netId = NetworkGetNetworkIdFromEntity(veh);
    self:setNetId(netId);

    local p = promise.new();
    utils.vehicle.SetDeformation(veh, self:getDeformations(), function()
        p:resolve();
    end)

    utils.vehicle.SetMods(veh, self:getMods());
    SetVehicleNumberPlateText(veh, self:getPlate());

    Citizen.Await(p);
end

module.GetById = function(id)
    return core.GetSyncObject("Vehicle", id);
end