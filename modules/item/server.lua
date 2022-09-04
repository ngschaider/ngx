---@diagnostic disable: deprecated
local logger = M("logger");
local class = M("class");
local core = M("core");

Item = class("Item", core.SyncObject);
core.RegisterSyncClass(Item);

Item.static.rpcWhitelist = {};
Item.static.name = "default";
Item.static.label = "Default";

function Item.static:Create(options)
    local id = MySQL.insert.await("INSERT INTO items (name, label) VALUES (?, ?)", {
        options.name,
        options.label,
    });

	return module.GetById(id);
end;

function Item:initialize(id, options)
    core.SyncObject.initialize(self, "Item", id, "items");
    logger.debug("Item:initialize", "id", id);
    self.options = options;

    self:syncProperty("id", true, false);
    self:syncProperty("name", true, true);
    self:syncProperty("label", true, true);
    self:syncProperty("inventoryId", true, true);
    self:syncProperty("isUsable", true, false);
    self:rpcMethod("getItemData", true);
    self:rpcMethod("use", true);
end

function Item:getId()
    return self:getData("id");
end;

function Item:getInventoryId()
    return self:getData("inventoryId");
end;

function Item:getInventory()
    local id = self:getInventoryId();
    if id then
        return M("inventory").GetById(id);
    else
        return nil;
    end
end;

function Item:setInventoryId(inventoryId)
    logger.debug("Item:setInventoryId", "inventoryId", inventoryId);
    logger.debug("Item:setInventoryId", "self:getId()", self:getId());
    self:setData("inventoryId", inventoryId);
end;

function Item:setInventory(inventory)
    self:setInventoryId(inventory.id);
end;

function Item:getName()
    return self:getData("name");
end;

function Item:getLabel()
    return self:getData("label");
end;

function Item:getItemData()
    return json.decode(self:getData("data"));
end;

function Item:setItemData(data)
    self:setData("data", json.encode(data));
end;

function Item:getIsUsable()
    return self:getData("isUsable");
end

function Item:setIsUsable(isUsable)
    self:setData("isUsable", isUsable);
end

function Item:use()
    logger.warn("Item " .. self:getName() .. " got used but has no usage implemented.");
end;

function Item:destroy()
    self:setData("destroyed", true);
end;




local registeredItems = {};
function RegisterItem(options)
    registeredItems[options.name] = options;
end;

module.GetById = function(id)
    logger.debug("(item) module.GetById", "id", id);
    local name = MySQL.scalar.await("SELECT name FROM items WHERE id=?", {id});
    local options = registeredItems[name];

    return core.GetSyncObject("Item", id, options);
end

-- Exports
run("server/beer.lua");