local class = M("class");
local logger = M("core").logger;
local callback = M("core").callback;
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
        tonumber(self:getData("positionX")),
        tonumber(self:getData("positionY")),
        tonumber(self:getData("positionZ"))
    );
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
    logger.debug("garage->class", "module.GetAll");
	local p = promise.new();
	callback.trigger("garage:getAllIds", function(ids)
		p:resolve(ids);
	end);
    logger.debug("garage->class", "module.GetAll", "resolving");
	local ids = Citizen.Await(p);

    logger.debug("garage->class", "module.GetAll", "iterating");
	local garages = {};
	for _,id in pairs(ids) do
		local garage = module.GetById(id);
		table.insert(garages, garage);
	end

	return garages;
end;