local utils = M("utils");
local callback = M("callback");
local logger = M("logger");
local class = M("class");
local Item = M("item");

local Inventory = class("Inventory");

Inventory.static.rpcWhitelist = {};

function Inventory:initialize(id)
	self.id = id;
end

function Inventory.static:Create(maxWeight)
	local id = MySQL.insert.await("INSERT INTO inventories (max_weight) VALUES (?)", {
		maxWeight,
	});

	return id;
end

function Inventory:getMaxWeight()
	return MySQL.scalar.await("SELECT max_weight FROM inventories WHERE id=?", {self.id});
end;
table.insert(Inventory.static.rpcWhitelist, "getMaxWeight");

function Inventory:setMaxWeight(newMaxWeight)
	MySQL.update.await("UPDATE inventories SET max_weight=? WHERE id=?", {
		newMaxWeight, 
		self.id,
	});
end;

function Inventory:getItemIds()
	local results = MySQL.query.await("SELECT id FROM items WHERE inventory_id=?", {self.id});
	
	local ids = {};
	for k,v in pairs(results) do
		table.insert(ids, v.id);
	end
	print(json.encode(ids));
	return ids;
end;
table.insert(Inventory.static.rpcWhitelist, "getItemIds");

function Inventory:getItems()
	local ids = self:getItemIds();

	local items = {};
	for _,id in pairs(ids) do
		local item = Item:new(id);
		table.insert(items, item);
	end

	return items;
end;

callback.register("inventory:rpc", function(playerId, cb, id, name, ...)
	local inventory = Inventory:new(id);

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


module = Inventory;