local logger = module.logger;
local User = M("user");

--[[
    stores the callbacks indexed by it's id 
    in a table which is indexed by the net event name
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

module.net = {};

module.net.on = function(name, cb)
    if not handlers[name] then
        handlers[name] = {};
    end

    local id = GetHandlerId();
    handlers[name][id] = cb;

    return id;
end

module.net.send = function(user, name, ...)
    local playerId = -1;
    if user then
        playerId = user:getPlayerId();
    end
    logger.debug("core->net", "S->[" .. playerId .. "]", name, ...);
    TriggerClientEvent("core:net:trigger", playerId, name, ...);
end

RegisterNetEvent("core:net:trigger", function(name, ...)
    local playerId = source;
    local user = User.GetByPlayerId(playerId);

    logger.debug("core->net", "[" .. playerId .. "]->S ", name, ...);

    if handlers[name] then
        for _,cb in pairs(handlers[name]) do
            cb(user, ...);
        end
    end
end);

AddEventHandler("playerDropped", function(reason)
    local playerId = source;
    local user = User.GetByPlayerId(playerId);
    module.send(user, "net:playerDropped", reason);
end)