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
    local id = MySQL.insert.await("INSERT INTO items (name, label) VALUES (?, ?)", {
        self.name,
        self.label,
    });

	return module.GetById(id);
end;

function Item:initialize(id)
    self.id = id;
    self._data = MySQL.single.await("SELECT * FROM items WHERE id=?", {self.id});
end

function Item:getInventoryId()
    return self._data.inventory_id;
end;
table.insert(Item.static.rpcWhitelist, "getInventoryId");

function Item:getInventory()
    local id = self:getInventoryId();
    if id then
        return M("inventory").GetById(id);
    else
        return nil;
    end
end;

function Item:setInventoryId(newInventoryId)
    print("Item:setInventoryId", "newInventoryId", newInventoryId);
    print("Item:setInventoryId", "self.id", self.id);
    MySQL.update.await("UPDATE items SET inventory_id=? WHERE id=?", {newInventoryId, self.id});
    self._data.inventory_id = newInventoryId;
end;
table.insert(Item.static.rpcWhitelist, "setInventoryId");

function Item:setInventory(inventory)
    self:setInventoryId(inventory.id);
end;

function Item:getName()
    return self._data.name;
end;
table.insert(Item.static.rpcWhitelist, "getName");

function Item:getLabel()
    return self._data.label;
end;
table.insert(Item.static.rpcWhitelist, "getLabel");

function Item:getData()
    return json.decode(self._data.data);
end;
table.insert(Item.static.rpcWhitelist, "getData");

function Item:setData(data)
    local dataStr = json.encode(data);
    MySQL.update.await("UPDATE items SET data=? WHERE id=?", {dataStr, self.id});
    self._data.data = dataStr;
end;

function Item:getIsUsable()
    return self._data.is_usable;
end
table.insert(Item.static.rpcWhitelist, "getIsUsable");

function Item:setIsUsable(newIsUsable)
    MySQL.update.await("UPDATE is_usable SET data=? WHERE id=?", {newIsUsable, self.id});
    self._data.is_usable = newIsUsable;
end

function Item:use()
    logger.warn("Item " .. self:getName() .. " got used but has no usage implemented.");
end;
table.insert(Item.static.rpcWhitelist, "use");

function Item:destroy()
    MySQL.query.await("DELETE FROM items WHERE id=?", {self.id});
    self = nil;
end;

callback.register("item:rpc", function(playerId, cb, id, name, ...)
	local item = module.GetById(id);

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