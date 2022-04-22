local Construct = function(id)
    local self = {};

    self.id = id;

    self.getData = function()
        local dataStr = MySQL.scalar.await("SELECT data FROM areas WHERE id=?", {self.id});
        return json.decode(dataStr);
    end;

    self.getVertices = function()
        local verticesStr = MySQL.scalar.await("SELECT vertices FROM areas WHERE id=?", {self.id});
        return json.decode(verticesStr);
    end;

end;

local Create = function(vertices, data)
    local id = MySQL.insert.await("INSERT INTO areas (vertices, data) VALUES (?, ?)", {
        json.encode(vertices),
        json.encode(data)
    });
    return module.getById(id);
end;

local areas = {};
module.getById = function(id)
    if not areas[id] then
        areas[id] = Construct(id);
    end
    return areas[id];
end;