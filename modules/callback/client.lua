local logger = M("logger");
local event = M("event");

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

module.trigger = function(name, cb, ...)
	logger.debug("triggered client->server->client callback " .. name);

    local requestId = GetAndConsumeRequestId();
	serverCallbacks[requestId] = cb;

	event.emitServer("callback:request", name, requestId, ...);
end;

event.onServer("callback:response", function(requestId, ...)
	-- developer does not need to provide a callback function when triggering a callback
	if serverCallbacks[requestId] then
		serverCallbacks[requestId](...);
		serverCallbacks[requestId] = nil;
	end
end);


local clientCallbacks = {};

module.register = function(name, cb)
	logger.debug("callback.register", name);
    clientCallbacks[name] = cb;
end;

event.onServer("callback:request", function(name, requestId, ...)
	if clientCallbacks[name] then
		clientCallbacks[name](function(...)
			event.emitServer("callback:response", requestId, ...);
		end, ...);
	else
		logger.warn("server->client->server callback " .. name .. " not found.");
	end
end);