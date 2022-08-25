local callback = M("callback");
local class = M("class");

local Item = class("Item");

function Item:initialize(id)
    self.id = id;
end

function Item:_rpc(name, ...)
    local p = promise.new();
    callback.trigger("item:rpc", function(...) 
        p:resolve(...);
    end, self.id, name, ...);
    return Citizen.Await(p);
end;

function Item:getName()
    return self:_rpc("getName");
end;

function Item:getType()
    return self:_rpc("getType");
end;

function Item:getInventoryId()
    return self:_rpc("getInventoryId");
end;

function Item:getInventory()
    local inventoryId = self:getInventoryId();
    return M("inventory"):new(inventoryId);
end;

function Item:setInventoryId(inventoryId)
    return self:_rpc("setInventoryId", inventoryId);
end;

function Item:setInventory(inventory)
    self:setInventoryId(inventory.id);
end;

function Item:getIsUsable()
    self:_rpc("getIsUsable");
end

function Item:use()
    self:_rpc("use");
end

module = Item;