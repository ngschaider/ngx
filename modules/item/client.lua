local callback = M("core").callback;
local class = M("class");
local core = M("core");
local logger = M("core").logger;

local Item = class("Item", core.SyncObject);
core.RegisterSyncClass(Item);

function Item:initialize(id)
    core.SyncObject.initialize(self, "Item", id, "items");
end

function Item:getName()
    return self:getData("name");
end;

function Item:getLabel()
    logger.debug("Item:getLabel", "self._data", json.encode(self._data));
    return self:getData("label");
end;

function Item:getInventoryId()
    return self:getData("inventoryId");
end;

function Item:getInventory()
    local inventoryId = self:getInventoryId();
    return M("inventory").GetById(inventoryId);
end;

function Item:setInventoryId(id)
    self:setData("inventoryId", id);
end;

function Item:setInventory(inventory)
    self:setData("inventoryId", inventory.id);
end;

function Item:getIsUsable()
    return self:getData("getIsUsable");
end

function Item:use()
    return self:rpc("use");
end

module.GetById = function(id)
    logger.debug("(item) module.GetById", "id", id);
    return core.GetSyncObject("Item", id);
end