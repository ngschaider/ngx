local core = M("core");
local logger = M("core").logger;
local class = M("class");
local Inventory = M("inventory");

Item = class("Item", core.SyncObject);
core.RegisterSyncClass(Item);

function Item:initialize(id)
    core.SyncObject.initialize(self, "Item", id, "items");

    logger.debug("item", "Item:initialize", "self:getName()", self:getName());
    self.options = GetOptions(self:getName());

    logger.debug("item", "initialize", "id", id);

    self:syncProperty("id", true, false);
    self:syncProperty("name", true, true);
    self:syncProperty("label", true, true);
    self:syncProperty("inventoryId", true, true);
    self:syncProperty("isUsable", true, false);
    self:syncProperty("isDroppable", true, false);
    self:syncProperty("data", true, false);
    self:rpcMethod("use", true);
    self:rpcMethod("drop", true);
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
        return Inventory.GetById(id);
    else
        return nil;
    end
end;

function Item:setInventoryId(inventoryId)
    logger.debug("item", "setInventoryId", "inventoryId", inventoryId);
    logger.debug("item", "setInventoryId", "self:getId()", self:getId());
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

function Item:getIsDroppable()
    return self:getData("isDroppable"); 
end

function Item:setIsDroppable(isDroppable)
    self:setData("isDroppable", isDroppable);
end

function Item:use()
    self.options.onUse(self);
end;

function Item:drop()
    logger.error("item", "Item dropping is not yet supported!");
end;

function Item:destroy()
    core.DeleteSyncObject(self);
    self = nil;
end;