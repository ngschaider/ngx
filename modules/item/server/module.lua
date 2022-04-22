local event = M("event");
local inventoryClass = M("inventory");

local items = {};

event.on("inventory:construct:after", function(inventory)
    inventory.getItemIds = function()
        local res = MySQL.query.await("SELECT id FROM items WHERE inventory_id=?", {inventory.id});

        local ids = {};
        for k,v in pairs(res) do
            table.insert(ids, v.id);
        end

        return ids;
    end;

    inventory.getItems = function()
        local ids = inventory.getItemIds();

        local items = {};
        for _,id in pairs(ids) do
            local item = module.getById(id);
            table.insert(items, item);
        end

        return items;
    end;
end);

local Create = function()

end;

local Construct = function(id)
    local self = {};

    self.id = id;

    self.rpcWhitelist = {"getInventoryId", "getName", "getType", "getData"};

    self.getInventoryId = function()
        local inventoryId = MySQL.scalar.await("SELECT inventory_id FROM items WHERE id=?", {self.id});
        return inventoryId;
    end;

    self.getInventory = function()
        local id = self.getInventoryId();
        return inventoryClass.getById(id);
    end;

    self.getName = function()
        local label = MySQL.scalar.await("SELECT label FROM items WHERE id=?", {self.id});
        return label;
    end;

    self.getType = function()
        local type = MySQL.scalar.await("SELECT type FROM items WHERE id=?", {self.id});
        return type;
    end;

    self.getData = function()
        local data = MySQL.scalar.await("SELECT data FROM items WHERE id=?", {self.id});
        return json.decode(data);
    end;

    return self;
end;

module.getById = function(id)
    if not items[id] then
        items[id] = Construct(id);
    end

    return items[id];
end;