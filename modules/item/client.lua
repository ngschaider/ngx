local class = M("class");
local core = M("core");
local logger = M("core").logger;

local Item = class("Item", core.SyncObject);
core.RegisterSyncClass(Item);

function Item:initialize(id)
    core.SyncObject.initialize(self, "Item", id, "items");

    self.options = nil;
end

function Item:getName()
    return self:getData("name");
end;

function Item:getLabel()
    logger.debug("item", "getLabel", "self._data", json.encode(self._data));
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
    return self:getData("isUsable");
end

function Item:use()
    return self:rpc("use");
end

function Item:drop()
    return self:rpc("drop");
end

function Item:getIsDroppable()
    return self:getData("isDroppable");
end

function Item:onMenuBuild()
    if self.options and self.options.onMenuBuild then
        self.options.onMenuBuild(self);
    end
end

local registeredItems = {};
module.RegisterItem = function(options)
    registeredItems[options.name] = options;
end;

module.GetById = function(id)
    local item = core.GetSyncObject("Item", id);
    if registeredItems[item:getName()] then
        item.options = registeredItems[item:getName()];
    end

    return item;
end


-- Item types
run("client/beer.lua");