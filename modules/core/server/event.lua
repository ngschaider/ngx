local logger = module.logger;

--[[
    stores the callbacks indexed by it's id 
    in a table which is indexed by the event name
]]
local handlers = {};

--[[
    stores last handler's id
]]
local handlerId = 0;

--[[
    increases the handlerId and returns it's current value;
]]
local GetHandlerId = function()
    handlerId = handlerId + 1;
    return handlerId;
end;

module.event = {};

module.event.on = function(name, cb)
    if not handlers[name] then
        handlers[name] = {};
    end

    local id = GetHandlerId();
    handlers[name][id] = cb;

    return id;
end

module.event.off = function(name, id)
    if handlers[name] then
        handlers[name][id] = nil;
    end
end


module.event.emitServer = function(name, ...)
    if handlers[name] then
        for _,cb in pairs(handlers[name]) do
            cb(...);
        end
    end
end

module.event.emitClient = function(name, playerId, ...)
    if handlers[name] then
        TriggerClientEvent("core:event:trigger", name, playerId, ...);
    end
end

RegisterNetEvent("core:event:trigger", function(name, ...)
    local playerId = source;

    logger.debug("[" .. playerId .. "]->S ", name, ...);

    if handlers[name] then
        for _,cb in pairs(handlers[name]) do
            cb(playerId, ...);
        end
    end
end);

AddEventHandler("playerDropped", function(reason)
    local playerId = source;
    module.emitServer("event:playerDropped", playerId, reason);
end)