local handlers = {};

local eventId = 0;

local GetEventId = function()
    eventId = eventId + 1;
    return eventId;
end;

module.onClient = function(name, cb)
    if name:sub(1,6) ~= "logger" then
        logger().debug("event.onClient", name);
    end

    local id = GetEventId();

    handlers[name] = handlers[name] or {};
    handlers[name][id] = cb;

    return id;
end;

module.offClient = function(name, id)
    logger().debug("event.offClient", name);
    handlers[name] = handlers[name] or {};
    handlers[name][id] = nil;
end;

module.emitClient = function(name, playerId, ...)
    logger().debug("-> client " .. playerId, name, ...);
    TriggerClientEvent("event:trigger", playerId, name, ...);
end;

module.emitShared = function(name, ...)
    module.emit(name, ...);
    module.emitClient(name, ...);
end;

module.onShared = function(name, cb)
    local id1 = module.on(name, cb);
    local id2 = module.onClient(name, cb);

    return id1, id2;
end;

module.offShared = function(name, id1, id2)
    module.off(name, id1);
    module.offClient(name, id2);
end;

RegisterNetEvent("event:trigger", function(name, ...)
    local playerId = source;

    handlers[name] = handlers[name] or {};

    for k,v in pairs(handlers[name]) do
        v(playerId, ...);
    end
end);