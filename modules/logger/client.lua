--[[
local event = M("event");

module.debug = function(msg, ...)
    event.emitServer("logger:debug", msg, ...);
end;

module.info = function(msg, ...)
    event.emitServer("logger:info", msg, ...);
end;

module.warn = function(msg, ...)
    event.emitServer("logger:warn", msg, ...);
end;

module.error = function(msg, ...)
    event.emitServer("logger:error", msg, ...);
end;
]]