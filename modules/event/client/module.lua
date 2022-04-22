local handlers = {};

local eventId = 0;

local GetEventId = function()
    eventId = eventId + 1;
    return eventId;
end;

module.onServer = function(name, cb)
    logger().debug("event.onServer", name);
    local id = GetEventId();

    handlers[name] = handlers[name] or {};
    handlers[name][id] = cb;

    return id;
end;

module.offServer = function(name, id)
    logger().debug("event.offServer", name);
    handlers[name] = handlers[name] or {};
    handlers[name][id] = nil;
end;

module.emitServer = function(name, ...)
    -- logger.debug will call module.emitServer - this prevents an infinite loop
    if name:sub(1, 6) ~= "logger" then
        logger().debug("-> server", name, ...);
    end
    TriggerServerEvent("event:trigger", name, ...);
end;

module.emitShared = function(name, ...)
    module.emitServer(name, ...);
    module.emit(name, ...);
end;

module.onShared = function(name, cb)
    local id1 = module.on(name, cb);
    local id2 = module.onServer(name, cb);

    return id1, id2;
end;

module.offShared = function(name, id1, id2)
    module.off(name, id1);
    module.offServer(name, id2);
end;

RegisterNetEvent("event:trigger", function(name, ...)
    handlers[name] = handlers[name] or {};

    for k,v in pairs(handlers[name]) do
        v(...);
    end
end);