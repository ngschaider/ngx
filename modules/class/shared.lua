local utils = M("utils");

local classes = {};

local GetClass = function(className)
    return utils.table.find(function(class)
        return class._class.name == className;
    end);
end;

--[[
    This function returns a class constructor
]]
module.CreateClass = function(options, func)
    if not options then
        error("'options' cannot be null");
    end
    if not options.name then
        error("'options' has to contain a 'name' key");
    end

    if options.parentName and not GetClass(options.parentName) then
        error("'options.parentName' has to be the name of an already created class");
    end

    return function(...)
        local instance = {};

        instance._class = {
            parentClasses = {},
            name = options.name,
        }

        if options.parentName then
            table.insert(instance._class.parents, options.parentName);
            local parentClass = GetClass(options.parentName);
            instance.super = function(...)
                local parentInstance = parentClass(...);
                for k,v in pairs(parentInstance) do
                    instance[k] = v;
                end
            end;
        end

        instance.is_a = function(className)
            if instance._class.name == className then
                return true;
            end
            return utils.table.contains(instance._class.parentClasses)
        end;

        func(instance, ...);

        return instance;
    end;
end;