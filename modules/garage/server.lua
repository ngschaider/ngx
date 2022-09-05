local class = M("class");
local core = M("core");
local logger = M("logger");
local Vehicle = M("vehicle");
local utils = M("utils");


local Garage = class("Garage", core.SyncObject);
core.RegisterSyncClass(Garage);

function Garage:initialize(id)
    core.SyncObject.initialize(self, "Garage", id, "garages");

    self:syncProperty("name", true, false);
    self.syncProperty("positionX", true, false);
    self.syncProperty("positionY", true, false);
    self.syncProperty("positionZ", true, false);
    self:rpcMethod("getVehicleIds", true);
end

function Garage:getName()
    return self:getData("name");
end

function Garage:getPosition()
    return vector3(
        self:getData("positionX"),
        self:getData("positionY"),
        self:getData("positionZ")
    )
end

function Garage:getVehicleIds()
    local results = MySQL.query.await("SELECT id FROM vehicles WHERE garageId=?", {self.id});
	local ids = utils.table.map(results, function(v)
		return v.id;
	end);
	return ids;
end

function Garage:getVehicles()
    local ids = self:getVehicleIds();
    local vehicles = utils.table.map(ids, function(id)
        return Vehicle.GetById(id);
    end)
end

module.GetById = function(id)
    return core.GetSyncObject("Garage", id);
end