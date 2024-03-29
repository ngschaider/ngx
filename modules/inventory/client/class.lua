local Item = M("item");
local class = M("class");
local logger = M("core").logger;
local utils = M("utils");
local core = M("core");

local Inventory = class("Inventory", core.SyncObject);
core.RegisterSyncClass(Inventory);

function Inventory:initialize(id)
	core.SyncObject.initialize(self, "Inventory", id, "inventories");
end

function Inventory:getMaxWeight()
	return self:getData("maxWeight");
end

function Inventory:getItemIds()
	return self:rpc("getItemIds");
end

function Inventory:getItems()
	logger.debug("inventory", "getItems", "getting item ids");
	local ids = self:getItemIds();
	logger.debug("inventory", "getItems", "ids", json.encode(ids));
	
	local items = utils.table.mapValues(ids, function(id)
		logger.debug("inventory", "Inventory:getItems", "id", id);
		logger.debug("inventory", "Calling Item.GetById(" .. id .. ")");
		return Item.GetById(id);
	end);

	return items;
end

module.GetById = function(id)
	logger.debug("inventory", "module.GetById", "id", id);
	return core.GetSyncObject("Inventory", id);
end;