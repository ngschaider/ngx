local logger = M("logger");

local handlers = {};

local handlerId = 0;
local GetHandlerId = function()
    handlerId = handlerId + 1;
    return handlerId;
end;

module.event = {};

module.event.on = function(name, cb)
    logger.debug("(core) module.event.on", "name", name);
    local id = GetHandlerId();

    if not handlers[name] then
        handlers[name] = {};
    end
    handlers[name][id] = cb;

    return id;
end;

module.event.off = function(name, id)
    logger.debug("(core) module.event.off", name);
    if not handlers[name] then
        handlers[name] = {};
    end
    handlers[name][id] = nil;
end;

module.event.emitServer = function(name, ...)
    logger.debug("C->S", name, ...);
    TriggerServerEvent("event:trigger", name, ...);
end;

module.event.emitClient = function(name, ...)
    if handlers[name] then
        for _,cb in pairs(handlers[name]) do
            cb(...);
        end
    end
end;

RegisterNetEvent("event:trigger", function(name, ...)
    handlers[name] = handlers[name] or {};

    logger.debug("S->C", name, ...);

    for _,cb in pairs(handlers[name]) do
        cb(...);
    end
end);