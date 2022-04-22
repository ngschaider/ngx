local Construct = function(id)
    local self = {};

    self.id = id;

    self.getLocked = function()
        return MySQL.scalar.await("SELECT locked FROM doors WHERE id=?", {self.id});
    end;

    self.setLocked = function(locked)
        MySQL.update.await("UPDATE doors SET locked=?", {locked});
        event.emitClient("door:locked", -1, self.id);
    end;

    self.getPosition = function()
        local res = MySQL.query.await("SELECT position_x, position_y, position_z FROM doors WHERE id=?", {self.id});
        return {
            x = res.position_x,
            y = res.position_y,
            z = res.position_z,
        };
    end;
    
    self.getModel = function()
        return MySQL.scalar.await("SELECT model FROM doors WHERE id=?", {self.id});
    end;

    return self;
end;

local Create = function(position, model, heading)
    local query = "INSERT INTO doors (locked, position_x, position_y, position_z, model, heading) VALUES (?, ?, ?, ?, ?, ?)";
    local id = MySQL.insert.await(query, {
        false,
        position.x,
        position.y, 
        position.z,
        model,
        heading
    });
    return module.getById(id);
end;

local doors = {};
module.getById = function(id)
    if not doors[id] then
        doors[id] = Construct(id);
    end

    return doors[id];
end;

