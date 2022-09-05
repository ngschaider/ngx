local class = M("class");
local logger = M("logger");
local utils = M("utils");
local core = M("core");

local Garage = class("Garage", core.SyncObject);
core.RegisterSyncClass(Garage);

function Garage:initialize(id)
    core.SyncObject.initialize(self, "Garage", id, "garages");
end

function Garage:getName()
    return self:getData("name");
end

function Garage:getVehicleIds()
    return self:rpc("getVehicleIds");
end

function Garage:getPosition()
    return vector3(
        self:getData("positionX"),
        self:getData("positionY"),
        self:getData("positionZ")
    )
end

function Garage:getVehicles()
    local ids = self:getVehicleIds();
    local vehicles = utils.table.map(ids, function(id)
        return Vehicle.GetById(id);
    end);
    return vehicles;
end

module.GetById = function(id)
    return core.GetSyncObject("Garage", id);
end

module.GetAll = function()
	local p = promise.new();
	callback.trigger("garage:getAll", function(ids)
		p:resolve(ids);
	end);
	local ids = Citizen.Await(p);

	local garages = {};
	for _,id in pairs(ids) do
		local garage = module.GetById(id);
		table.insert(garages, garage);
	end

	return garages;
end;