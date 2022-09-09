run("client/class.lua");

local Character = M("character");
local logger = M("core").logger;
local core = M("core");


local registeredItems = {};
module.Register = function(options)
    registeredItems[options.name] = options;
end;

module.GetById = function(id)
    logger.debug("item", "module.GetById", "id", id);
    local item = core.GetSyncObject("Item", id);
    logger.debug("item", "module.GetById", "item.id", item.id);
    if registeredItems[item:getName()] then
        item.options = registeredItems[item:getName()];
    end

    return item;
end

Character.onCharacterSpawned:Add(function(character)
    for _,options in pairs(registeredItems) do
        if options.onCharacterSpawned then
            options.onCharacterSpawned(character);
        end
    end
end);


-- Item types
run("client/beer.lua");
--run("client/weapons.lua");