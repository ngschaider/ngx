local logger = M("logger");

local handlers = {};
local eventId = 0;

local GetEventId = function()
    eventId = eventId + 1;
    return eventId;
end;

module.on = function(name, cb)
    logger.debug("event.on", name);
    local id = GetEventId();

    handlers[name] = handlers[name] or {};
    handlers[name][id] = cb;

    return id;
end;

module.once = function(name, cb)
    logger.debug("event.once", name);
    local id = on(name, function(...)
        module.off(id);
        cb(...);
    end);
end;

module.off = function(name, id)
    logger.debug("event.off", name);
    handlers[name] = handlers[name] or {};
    handlers[name][id] = nil;
end;

module.emit = function(name, ...)
    handlers[name] = handlers[name] or {};

    for k,v in pairs(handlers[name]) do
        v(...);
    end
end;


AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return;
    end
    
    module.emit("event:ResourceStop");    
end)
