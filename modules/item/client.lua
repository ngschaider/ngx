run("client/class.lua");

local Character = M("character");


local registeredItems = {};
module.Register = function(options)
    registeredItems[options.name] = options;
end;

module.GetById = function(id)
    local item = core.GetSyncObject("Item", id);
    if registeredItems[item:getName()] then
        item.options = registeredItems[item:getName()];
    end

    return item;
end

Character.onCharacterSpawned:Add(function(character)
    for _,options in pairs(registeredItems) do
        options.onCharacterSpawned(character);
    end
end);


-- Item types
run("client/beer.lua");
run("client/weapons.lua");