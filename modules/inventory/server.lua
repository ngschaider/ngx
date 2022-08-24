local utils = M("utils");
local callback = M("callback");
local logger = M("logger");
local class = M("class");

module.Create = function(maxWeight)
	local id = MySQL.insert.await("INSERT INTO inventories (max_weight) VALUES (?)", {
		maxWeight,
	});

	return id;
end;

local Construct = class.CreateClass({
	name = "Inventory",
}, function(self, id)
    self.id = id;

	self.rpcWhitelist = {};

	self.getMaxWeight = function()
		local results = MySQL.scalar.await("SELECT max_weight FROM inventories WHERE id=?", {self.id});
		return res.max_weight;
	end;
	table.insert(self.rpcWhitelist, "getMaxWeight");

	self.setMaxWeight = function(newMaxWeight)
		MySQL.update.await("UPDATE inventories SET max_weight=? WHERE id=?", {
			newMaxWeight, 
			self.id,
		});
	end;

    self.getItemIds = function()
        local results = MySQL.query.await("SELECT id FROM items WHERE inventory_id=?", {self.id});
		
		local ids = {};
		for k,v in pairs(results) do
			table.insert(ids, v.id);
		end
		print(json.encode(ids));
		return ids;
    end;
	table.insert(self.rpcWhitelist, "getItemIds");

    self.getItems = function()
        local ids = self.getItemIds();

        local items = {};
        for _,id in pairs(ids) do
            local item = itemClass.getById(id);
            table.insert(items, item);
        end

        return items;
    end;
end);

module.getById = function(id)
	return Construct(id);
end;

callback.register("inventory:rpc", function(playerId, cb, id, name, ...)
	local inventory = module.getById(id);

	if not inventory then
		logger.warn("Inventory not found - rpc failed");
		return;
	end

	if not utils.table.contains(inventory.rpcWhitelist, name) then
		logger.warn("Requested inventory rpc " .. name .. " not whitelisted - rpc failed");
		return;
	end

	cb(inventory[name](...));
end);