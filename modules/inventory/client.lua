local callback = M("core").callback;
local Item = M("item");
local class = M("class");
local logger = M("logger");
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
	logger.debug("Inventory:getItems", "getting item ids");
	local ids = self:getItemIds();
	logger.debug("Inventory:getItems", "ids", json.encode(ids));
	
	local items = utils.table.map(ids, function(id)
		logger.debug("Inventory:getItems", "id", id);
		return Item.GetById(id);
	end);

	return items;
end

module.GetById = function(id)
	logger.debug("(inventory) module.GetById", "id", id);
	return core.GetSyncObject("Inventory", id);
end;