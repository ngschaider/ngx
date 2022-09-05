local event = module.event;
local logger = module.logger;

local serverCallbacks = {};
local lastRequestId = 0;

local GetAndConsumeRequestId = function()
    lastRequestId = lastRequestId + 1;

    if lastRequestId > 65535 then
        lastRequestId = 0;
    end

	if serverCallbacks[lastRequestId] then
		logger.warn("Overriding client->server->client callback with request id " .. lastRequestId);
	end

    return lastRequestId;
end;

module.callback = {};

module.callback.trigger = function(name, cb, ...)
	logger.debug("triggered client->server->client callback " .. name);

    local requestId = GetAndConsumeRequestId();
	serverCallbacks[requestId] = cb;

	event.emitServer("core:callback:request", name, requestId, ...);
end;

event.onServer("core:callback:response", function(requestId, ...)
	-- developer does not need to provide a callback function when triggering a callback
	if serverCallbacks[requestId] then
		serverCallbacks[requestId](...);
		serverCallbacks[requestId] = nil;
	end
end);


local clientCallbacks = {};

module.callback.register = function(name, cb)
	logger.debug("(core) module.callback.register", name);
    clientCallbacks[name] = cb;
end;

event.onServer("core:callback:request", function(name, requestId, ...)
	if clientCallbacks[name] then
		clientCallbacks[name](function(...)
			event.emitServer("core:callback:response", requestId, ...);
		end, ...);
	else
		logger.warn("server->client->server callback " .. name .. " not found.");
	end
end);