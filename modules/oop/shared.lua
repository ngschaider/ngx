local utils = M("utils");

local classes = {};

--[[
    returns a class by it's name
]]
module.GetClass = function(name)
    return classes[name];
end;

--[[
    returns a list of all classes;
]]
module.GetAllClasses = function()
    return classes;
end;


--[[
    options: {
        name: string,
        initFunc: function(self, ...),
        parent: class|nil,
    }
]]
local CreateClassInternal = function(options)
    if not options.name then
        logger.error("CreateClassInternal requires a name");
        return;
    end
    if classes[options.name] then
        logger.error("Class with name", options.name, "already exists");
        return;
    end

    local parents = {};
    if options.parent then
        parents = utils.table.concat(options.parent.parents, options.parent);
    end

    local class = {
        _class = {
            name = options.name,
            parents = parents,
            parent = options.parent,
        },

        constructor = function(...)
            local instance = {};
            instance._class = class._class;

            if options.parent then
                instance.super = function(...)
                    local parentInstance = options.parent.constructor(...);
                    for k,v in pairs(parentInstance) do
                        instance[k] = v;
                    end
                end;
            end

            instance.instance_of = function(class)
                if instance._class.name == class._class.name then
                    return true;
                end
                for k,v in pairs(instance._class.parents) do
                    if v._class.name == class._class.name then
                        return true;
                    end
                end
                return false;
            end,

            options.initFunc(instance, ...);
            return instance;
        end,
    }

    classes[options.name] = class;

    return class;
end;

module.CreateClass = function(name, initFunc) 
    return CreateClassInternal({
        name = name,
        initFunc = initFunc,
        parent = nil,
    });
end;


module.ExtendClass = function(name, parent, initFunc)
    return CreateClassInternal({
        name = name,
        initFunc = initFunc,
        parent = parent,
    });
end;