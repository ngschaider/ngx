local event = M("event");

local inventories = {};

local Construct = function(id)
    local self = {};

    self.id = id;

    event.emit("inventory:construct:after", self);

    return self;
end;

local Create = function()
    local id = MySQL.insert.await("INSERT INTO inventories () VALUES ();");
    return module.getById(id);
end;

event.on("character:create:after", function(character)
    local inventory = Create();
    MySQL.update.await("UPDATE characters SET inventory_id=? WHERE id=?", {inventory.id, character.id});
end);

event.on("character:construct:after", function(character)
    character.getInventory = function()
        local inventoryId = MySQL.scalar.await("SELECT inventory_id FROM characters WHERE id=?", {character.id});
        return module.getById(inventoryId);
    end;
end);

module.getById = function(id)
    if not inventories then
        inventories[id] = Construct(id);
    end

    return inventories[id];
end;