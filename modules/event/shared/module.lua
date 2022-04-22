-- dont load module in the beginng because we will get stuck in a loop
logger = function() 
    return M("logger");
end;

local handlers = {};
local eventId = 0;

local GetEventId = function()
    eventId = eventId + 1;
    return eventId;
end;

module.on = function(name, cb)
    logger().debug("on", name);
    local id = GetEventId();

    handlers[name] = handlers[name] or {};
    handlers[name][id] = cb;

    return id;
end;

module.once = function(name, cb)
    logger().debug("once", name);
    local id = on(name, function(...)
        module.off(id);
        cb(...);
    end);
end;

module.off = function(name, id)
    logger().debug("off", name);
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