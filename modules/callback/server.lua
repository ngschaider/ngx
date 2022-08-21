local logger = M("logger");
local event = M("event");
local utils = M("utils");

local serverCallbacks = {};

module.register = function(name, cb)
	logger.info("callback.register: " .. name);
	serverCallbacks[name] = cb;
end

event.onClient("callback:request", function(playerId, name, requestId, ...)
	if serverCallbacks[name] then
		logger.debug("executing client->server->client callback function", playerId, name, ...);
		serverCallbacks[name](playerId, function(...)
			--logger.debug("-> client " .. playerId, "callback:response", name, ...);
			event.emitClient("callback:response", playerId, requestId, ...);
		end, ...);
	else
		logger.warn("client->server->client callback " .. name .. " not found.");
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
		logger.warn("override server->client->server callback with request id " .. lastRequestId);
	end

    return lastRequestId;
end

module.trigger = function(name, playerId, cb, ...)
	logger.debug("triggered server->client->server callback " .. name);

    local requestId = GetAndConsumeRequestId();
	clientCallbacks[requestId] = cb;

	event.emitClient("callback:request", playerId, name, requestId, ...)
end;

event.onClient("callback:response", function(playerId, requestId, ...)
	clientCallbacks[requestId](...);
	clientCallbacks[requestId] = nil;
end)
