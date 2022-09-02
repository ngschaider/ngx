---@diagnostic disable: deprecated
local logger = M("logger");
local utils = M("utils");
local callback = M("callback");
local class = M("class");

Item = class("Item");

Item.static.rpcWhitelist = {};
Item.static.name = "default";
Item.static.label = "Default";

function Item.static:Create()
    print()
    local id = MySQL.insert.await("INSERT INTO items (name, label) VALUES (?, ?)", {
        self.name,
        self.label,
    });

	return Item:new(id);
end;

print("    Item.static:Create assigned");

function Item:initialize(id)
    self.id = id;
    self.usable = false;
end

function Item:getInventoryId()
    local id = MySQL.scalar.await("SELECT inventory_id FROM items WHERE id=?", {self.id});
    return id;
end;
table.insert(Item.static.rpcWhitelist, "getInventoryId");

function Item:getInventory()
    local id = self:getInventoryId();
    if id then
        return M("inventory"):new(id);
    else
        return nil;
    end
end;

function Item:setInventoryId(inventoryId)
    print("Item:setInventoryId", "inventoryId", inventoryId);
    print("Item:setInventoryId", "self.id", self.id);
    MySQL.update.await("UPDATE items SET inventory_id=? WHERE id=?", {inventoryId, self.id});
end;
table.insert(Item.static.rpcWhitelist, "setInventoryId");

function Item:setInventory(inventory)
    self:setInventoryId(inventory.id);
end;

function Item:getName()
    local name = MySQL.scalar.await("SELECT name FROM items WHERE id=?", {self.id});
    return name;
end;
table.insert(Item.static.rpcWhitelist, "getName");

function Item:getLabel()
    local label = MySQL.scalar.await("SELECT label FROM items WHERE id=?", {self.id});
    return label;
end;
table.insert(Item.static.rpcWhitelist, "getLabel");

function Item:getData()
    local data = MySQL.scalar.await("SELECT data FROM items WHERE id=?", {self.id});
    return json.decode(data);
end;
table.insert(Item.static.rpcWhitelist, "getData");

function Item:setData(data)
    local dataStr = json.encode(data);
    MySQL.update.await("UPDATE items SET data=? WHERE id=?", {dataStr, self.id});
end;

function Item:getIsUsable()
    return self.isUsable;
end
table.insert(Item.static.rpcWhitelist, "getIsUsable");

function Item:use()
    logger.warn("Item " .. self:getName() .. " got used but has not usage implemented.");
end;
table.insert(Item.static.rpcWhitelist, "use");

function Item:destroy()
    MySQL.query.await("DELETE FROM items WHERE id=?", {self.id});
end;

callback.register("item:rpc", function(playerId, cb, id, name, ...)
	local item = Item:new(id);

	if not item then
		logger.warn("Item not found - rpc failed");
		return;
	end

	if not utils.table.contains(Item.rpcWhitelist, name) then
		logger.warn("Requested item rpc " .. name .. " not whitelisted - rpc failed");
		return;
	end

	-- we have to pass the item object because we are not using the colon syntax like item:getLabel(...)
	cb(item[name](item, ...));
end);



local registeredItems = {};
function RegisterItem(itemClass)
    registeredItems[itemClass.name] = itemClass;
end;

module.GetItemClass = function(name)
    return registeredItems[name];
end

local cache = {};
module.GetById = function(id)
    if not cache[id] then
        local name = MySQL.scalar.await("SELECT name FROM items WHERE id=?", {id});
        local specificItemClass = module.GetItemClass(name);
        cache[id] = specificItemClass:new(id);
    end

    return cache[id];
end

-- Exports
run("server/beer.lua");