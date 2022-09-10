local class = M("class");
local core = M("core");
local Garage = M("garage");
local logger = M("core").logger;
local Character = M("character");
local utils = M("utils");
local callback = M("core").callback;

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

function Vehicle:getName()
    return self:getData("name");
end

function Vehicle:setName(name)
    self:setData("name", name);
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
    if self:getNetId() then
        return;
    end

    local garage = self:getGarage();

    utils.streaming.RequestModel(self:getModel());
    local veh = CreateVehicle(self:getModel(), garage:getPosition(), 0.0, true, true);
    local netId = NetworkGetNetworkIdFromEntity(veh);
    self:setNetId(netId);

    if self:getDeformations() then
        utils.vehicle.SetDeformation(veh, self:getDeformations())
    end

    local primaryColor = self:getPrimaryColor();
    local secondaryColor = self:getSecondaryColor();
    if primaryColor ~= nil and secondaryColor ~= nil then
        print("setting", veh, primaryColor, secondaryColor);
        SetVehicleColours(veh, primaryColor, secondaryColor);
    end

    if self:getMods() then
        utils.vehicle.SetMods(veh, self:getMods());
    end

    SetVehicleNumberPlateText(veh, self:getPlate());
end

function Vehicle:save()
    local netId = self:getNetId();
    if not netId then
        return;
    end

    local veh = NetworkGetEntityFromNetworkId(netId);
    local deformation = utils.vehicle.GetDeformation(veh);
    --local modKit = GetVehicleModKit(veh);
    --local mods = utils.vehicle.GetMods(veh);

    self:rpc("save", deformation);
end

function Vehicle:despawn()
    if not self:getNetId() then
        return;
    end

    local veh = NetworkGetEntityFromNetworkId(self:getNetId());
    DeleteVehicle(veh);

    self:setNetId(nil);
end

module.GetById = function(id)
    return core.GetSyncObject("Vehicle", id);
end

module.GetByNetId = function(netId)
    logger.debug("vehicle", "module.GetByNetId", "netId", netId);
    local id = callback.trigger("vehicle:getIdByNetId", netId);
    logger.debug("vehicle", "module.GetByNetId", "id", json.encode(id));

    if not id then
        return nil;
    end

    return module.GetById(id);
end