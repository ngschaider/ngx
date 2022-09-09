run("server/class.lua");

local logger = M("core").logger;
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
run("server/weapons.lua");