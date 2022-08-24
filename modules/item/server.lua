local logger = M("logger");
local utils = M("utils");
local callback = M("callback");
local OOP = M("oop");

local Item = class("Item");

function Item:initialize(id)
    self.id = id;
end

Item.static.rpcWhitelist = {};

Item.static.Create = function(SpecificItem)
    local id = MySQL.insert.await("INSERT INTO items (name, label) VALUES (?, ?)", {
        SpecificItem.name,
        SpecificItem.label,
    });

	return Item.GetById(id);
end;

function Item:getInventoryId()
    local id = MySQL.scalar.await("SELECT inventory_id FROM items WHERE id=?", {self.id});
    return id;
end;
table.insert(Item.static.rpcWhitelist, "getInventoryId");

function Item:getInventory()
    local id = self.getInventoryId();
    if id then
        return M("inventory").GetById(id);
    else
        return nil;
    end
end;

function Item:setInventoryId (inventoryId)
    print("setInventoryId", json.encode(inventoryId), json.encode(self.id));
    MySQL.update.await("UPDATE items SET inventory_id=? WHERE id=?", {inventoryId, self.id});
end;
table.insert(Item.static.rpcWhitelist, "setInventoryId");

function Item:setInventory(inventory)
    self.setInventoryId(inventory.id);
end;

function Item:getName()
    local name = MySQL.scalar.await("SELECT name FROM items WHERE id=?", {self.id});
    return name;
end;
table.insert(Item.static.rpcWhitelist, "getName");

function Item:getType()
    print("querying type");
    local type = MySQL.scalar.await("SELECT type FROM items WHERE id=?", {self.id});
    print("got type from db", type);
    return type;
end;
table.insert(Item.static.rpcWhitelist, "getType");

function Item:use()
    local config = self.getConfig();
    if config.use then
        config.use(self);
    end
end;
table.insert(Item.static.rpcWhitelist, "use");

function Item:getConfig()
    local type = self.getType();
    utils.table.find(ItemConfigs, function(itemConfig) 
        return itemConfig.type == type;
    end);
end;

function Item:destroy()
    MySQL.query.await("DELETE FROM items WHERE id=?", {self.id});
end;

callback.register("item:rpc", function(playerId, cb, id, name, ...)
	local item = module.getById(id);

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
    local itemId = Item.Create("beer");
    print("getting beer");
    local item = Item.getById(itemId);
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


local registeredItems = {};
function registerItem(item)
    registeredItems[item.name] = item;
end;

module.GetItemClass = function(name)
    return registeredItems[name];
end

module.GetById = function(id)
    local name = MySQL.scalar.await("SELECT name FROM items WHERE id=?", {id});
    local itemClass = module.GetItemClass(name);
    return itemClass:New(id);
end;

-- Exports
run("server/beer.lua");