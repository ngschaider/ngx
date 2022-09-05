local event = module.event;
local logger = M("logger");

local serverCallbacks = {};

module.callback = {};

module.callback.register = function(name, cb)
	logger.info("(core) module.callback.register: " .. name);
	serverCallbacks[name] = cb;
end

event.onClient("core:callback:request", function(playerId, name, requestId, ...)
	if serverCallbacks[name] then
		logger.debug("executing C->S->C callback function", playerId, name, ...);
		serverCallbacks[name](playerId, function(...)
			--logger.debug("-> client " .. playerId, "core:callback:response", name, ...);
			event.emitClient("core:callback:response", playerId, requestId, ...);
		end, ...);
	else
		logger.warn("C->S->C callback " .. name .. " not found.");
	end
end)


local clientCallbacks = {};
local lastRequestId = 0;

local GetAndConsumeRequestId = function()
    lastRequestId = lastRequestId + 1;

    if lastRequestId > 65535 then
        lastRequestId = 0;
    end

	if clientCallbacks[lastRequestId] then
		logger.warn("overriding S->C->S callback with request id " .. lastRequestId);
	end

    return lastRequestId;
end

module.callback.trigger = function(name, playerId, cb, ...)
	logger.debug("triggered S->C->S callback " .. name);

    local requestId = GetAndConsumeRequestId();
	clientCallbacks[requestId] = cb;

	event.emitClient("core:callback:request", playerId, name, requestId, ...)
end;

event.onClient("core:callback:response", function(playerId, requestId, ...)
	clientCallbacks[requestId](...);
	clientCallbacks[requestId] = nil;
end)
