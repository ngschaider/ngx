local logger = module.logger;

local handlers = {};

local handlerId = 0;
local GetHandlerId = function()
    handlerId = handlerId + 1;
    return handlerId;
end;

module.net = {};

module.net.on = function(name, cb)
    logger.debug("core->net", "(core) module.net.on", "name", name);
    local id = GetHandlerId();

    if not handlers[name] then
        handlers[name] = {};
    end
    handlers[name][id] = cb;

    return id;
end;

module.net.send = function(name, ...)
    logger.debug("core->net", "C->S", name, ...);
    TriggerServerEvent("core:net:trigger", name, ...);
end;

RegisterNetEvent("core:net:trigger", function(name, ...)
    handlers[name] = handlers[name] or {};

    logger.debug("core->net", "S->C", name, ...);

    for _,cb in pairs(handlers[name]) do
        cb(...);
    end
end);




module.net.on("core:print", function(msg)
    print(msg);
end);