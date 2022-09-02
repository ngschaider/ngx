local utils = M("utils");
local callback = M("callback");
local logger = M("logger");
local class = M("class");
local Item = M("item");

local Inventory = class("Inventory");

Inventory.static.rpcWhitelist = {};

function Inventory:initialize(id)
	self.id = id;
	self._data = MySQL.single.await("SELECT * FROM inventories WHERE id=?", {self.id});
end

function Inventory:getMaxWeight()
	return self._data.max_weight;
end;
table.insert(Inventory.static.rpcWhitelist, "getMaxWeight");

function Inventory:setMaxWeight(newMaxWeight)
	MySQL.update.await("UPDATE inventories SET max_weight=? WHERE id=?", {
		newMaxWeight,
		self.id,
	});
	self._data.max_weight = newMaxWeight;
end;

function Inventory:getItemIds()
	local results = MySQL.query.await("SELECT id FROM items WHERE inventory_id=?", {self.id});
	
	local ids = utils.table.map(results, function(v)
		return v.id;
	end);
	print("Inventory.getItemIds", "ids", json.encode(ids));
	return ids;
end;
table.insert(Inventory.static.rpcWhitelist, "getItemIds");

function Inventory:getItems()
	local ids = self:getItemIds();

	local items = utils.table.map(ids, function(id)
		return Item.GetById(id);
	end);
	
	return items;
end;

callback.register("inventory:rpc", function(playerId, cb, id, name, ...)
	local inventory = module.GetById(id);

	if not inventory then
		logger.warn("Inventory not found - rpc failed");
		return;
	end

	if not utils.table.contains(Inventory.rpcWhitelist, name) then
		logger.warn("Requested inventory rpc " .. name .. " not whitelisted - rpc failed");
		return;
	end

	-- we have to pass the inventory object because we are not using the colon syntax like inventory:getMaxWeight(...)
	cb(inventory[name](inventory, ...));
end);


module.Create = function(maxWeight)
	local id = MySQL.insert.await("INSERT INTO inventories (max_weight) VALUES (?)", {
		maxWeight,
	});

	return id;
end

local cache = {};
module.GetById = function(id)
	if not cache[id] then
		cache[id] = Inventory:new(id);
	end
	
	return cache[id];
end;