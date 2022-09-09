local class = M("class");
local logger = M("core").logger;
local utils = M("utils");
local core = M("core");
local Marker = M("marker");

local Garage = class("Garage", core.SyncObject);
core.RegisterSyncClass(Garage);

function Garage:initialize(id)
    core.SyncObject.initialize(self, "Garage", id, "garages");

    self.notification = core.notification.CreateHelpNotification("Drücke ~INPUT_CONTEXT~ um auf die Garage zuzugreifen");

    self.marker = Marker.Create(self:getPosition());
    self.marker.scale = vector3(3.0, 3.0, 0.2);
    self.marker.onEnter:Add(function()
        self.notification.visible = true;
    end);
    self.marker.onExit:Add(function()
        self.notification.visible = false;
    end);
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
    local vehicles = utils.table.mapValues(ids, function(id)
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
	core.callback.trigger("garage:getAllIds", function(ids)
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