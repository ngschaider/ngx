--[[
local event = M("event");

module.debug = function(msg, ...)
    print("^3[DEBUG]^7 " .. msg, ...);
end;
event.onClient("logger:debug", function(playerId, msg, ...)
    module.debug("[" .. playerId .. "] " .. msg, ...);
end);

module.info = function(msg, ...)
    print("^3[INFO]^7 " .. msg, ...);
end;
event.onClient("logger:info", function(playerId, msg, ...)
    module.info("[" .. playerId .. "] " .. msg, ...);
end);

module.warn = function(msg, ...)
    print("^3[WARNING]^7 " .. msg, ...);
end;
event.onClient("logger:warn", function(playerId, msg, ...)
    module.warn("[" .. playerId .. "] " .. msg, ...);
end);

module.error = function(msg, ...)
    print("^3[ERROR]^7 " .. msg, ...);
end;
event.onClient("logger:error", function(playerId, msg, ...)
    module.error("[" .. playerId .. "] " .. msg, ...);
end);
]]

