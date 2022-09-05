local utils = M("utils");
local callback = M("core").callback;
local logger = M("core").logger;
local class = M("class");
local Item = M("item");
local core = M("core");

local Inventory = class("Inventory", core.SyncObject);
core.RegisterSyncClass(Inventory);

function Inventory:initialize(id)
	core.SyncObject.initialize(self, "Inventory", id, "inventories");

	self:syncProperty("maxWeight", true, false);
	self:rpcMethod("getItemIds", true);
end

function Inventory:getMaxWeight()
	return self:getData("maxWeight");
end;

function Inventory:setMaxWeight(maxWeight)
	self:setData("maxWeight", maxWeight);
end;

function Inventory:getItemIds()
	local results = MySQL.query.await("SELECT id FROM items WHERE inventoryId=?", {self.id});
	
	local ids = utils.table.map(results, function(v)
		return v.id;
	end);
	logger.debug("inventory", "getItemIds", "ids", json.encode(ids));
	return ids;
end;

function Inventory:getItems()
	local ids = self:getItemIds();

	local items = utils.table.map(ids, function(id)
		return Item.GetById(id);
	end);
	
	return items;
end;

module.Create = function(maxWeight)
	local id = MySQL.insert.await("INSERT INTO inventories (max_weight) VALUES (?)", {
		maxWeight,
	});

	return module.GetById(id);
end

module.GetById = function(id)
	logger.debug("inventory", "module.GetById", "id", id);
	return core.GetSyncObject("Inventory", id);
end;