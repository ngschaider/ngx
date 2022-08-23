local logger = M("logger");
local utils = M("utils");
local callback = M("callback");

module.Create = function(type)
    local id = MySQL.insert.await("INSERT INTO items (name, type) VALUES (?, ?)", {
        ItemClass.defaultName,
        ItemClass.type,
    });

	return id;
end;

local Construct = function(id)
    local self = {};

    self.id = id;

    self.rpcWhitelist = {};

    self.getInventoryId = function()
        local id = MySQL.scalar.await("SELECT inventory_id FROM items WHERE id=?", {self.id});
		return id;
    end;
    table.insert(self.rpcWhitelist, "getInventoryId");

    self.getInventory = function()
        local id = self.getInventoryId();
        if id then
            return M("inventory").getById(id);
        else
            return nil;
        end
    end;

    self.setInventoryId = function(inventoryId)
        print("setInventoryId", json.encode(inventoryId), json.encode(self.id));
        MySQL.update.await("UPDATE items SET inventory_id=? WHERE id=?", {inventoryId, self.id});
    end;
    table.insert(self.rpcWhitelist, "setInventoryId");

    self.setInventory = function(inventory)
        self.setInventoryId(inventory.id);
    end;

    self.getName = function()
        local name = MySQL.scalar.await("SELECT name FROM items WHERE id=?", {self.id});
        return name;
    end;
    table.insert(self.rpcWhitelist, "getName");

    self.getType = function()
        print("querying type");
        local type = MySQL.scalar.await("SELECT type FROM items WHERE id=?", {self.id});
        print("got type from db", type);
        return type;
    end;
    table.insert(self.rpcWhitelist, "getType");

    self.use = function()
        local config = self.getConfig();
        if config.use then
            config.use(self);
        end
    end;
    table.insert(self.rpcWhitelist, "use");

    self.getConfig = function()
        local type = self.getType();
        utils.table.find(ItemConfigs, function(itemConfig) 
            return itemConfig.type == type;
        end);
    end;

    self.Destroy = function()
        MySQL.query.await("DELETE FROM items WHERE id=?", {self.id});
    end;

    return self;
end;

module.getById = function(id)
    return Construct(id);
end;

callback.register("item:rpc", function(playerId, cb, id, name, ...)
	local item = ItemClass.getById(id);

	if not item then
		logger.warn("Item not found - rpc failed");
		return;
	end

	if not utils.table.contains(item.rpcWhitelist, name) then
		logger.warn("Requested item rpc " .. name .. " not whitelisted - rpc failed");
		return;
	end

	cb(item[name](...));
end);

RegisterCommand("beer", function(playerId, args, rawCommand)
    print("giving player a beer");
    local itemId = Create("beer");
    print("getting beer");
    local item = module.getById(itemId);
    print("beer");

    print("getting character");
    local character = M("character").getByPlayerId(playerId);
    if not character then
        logger.debug("failed to get current character");
        return;
    end

    print("getting inventory")
    local inventory = character.getInventory();
    print("setting item inventory_id", inventory.id);
    item.setInventoryId(inventory.id)
end, true);