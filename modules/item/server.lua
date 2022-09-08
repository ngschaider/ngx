local logger = M("core").logger;
local class = M("class");
local core = M("core");


local registeredItems = {};

local GetOptions = function(name)
    local options = registeredItems[name];
    if not options then
        logger.warn("item", "GetOptions", "Using default options", "name", name);
        options = {
            name = self:getName(),
            label = "404_" .. self:getName(),
            isUsable = false,
            isDroppable = false,
        };
    end

    return options;
end


local Item = class("Item", core.SyncObject);
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
        return M("inventory").GetById(id);
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

module.Create = function(name)
    local options = GetOptions(name);

    local id = MySQL.insert.await("INSERT INTO items (name, label, isUsable, isDroppable) VALUES (?, ?, ?, ?)", {
        options.name,
        options.label,
        options.isUsable or false,
        options.isDroppable or false,
    });

	return module.GetById(id);
end;

module.GetById = function(id)
    return core.GetSyncObject("Item", id);
end

module.Register = function(options)
    registeredItems[options.name] = options;
end;

-- Item types
run("server/beer.lua");