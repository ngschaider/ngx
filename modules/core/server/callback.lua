local net = module.net;
local logger = module.logger;

local serverCallbacks = {};

module.callback = {};

module.callback.register = function(name, cb)
	logger.info("core.callback", "module.callback.register: " .. name);
	serverCallbacks[name] = cb;
end

net.on("core:callback:request", function(user, name, requestId, ...)
	if serverCallbacks[name] then
		logger.debug("core->callback", "executing C->S->C callback function", user.id, name, ...);
		serverCallbacks[name](user, function(...)
			net.send(user, "core:callback:response", requestId, ...);
		end, ...);
	else
		logger.warn("core->callback", "C->S->C callback " .. name .. " not found.");
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
		logger.warn("core->callback", "overriding S->C->S callback with request id " .. lastRequestId);
	end

    return lastRequestId;
end

module.callback.trigger = function(user, name, cb, ...)
	logger.debug("core->callback", "triggered S->C->S callback " .. name);

    local requestId = GetAndConsumeRequestId();
	clientCallbacks[requestId] = cb;

	net.send(user, "core:callback:request", name, requestId, ...)
end;

net.on("core:callback:response", function(playerId, requestId, ...)
	clientCallbacks[requestId](...);
	clientCallbacks[requestId] = nil;
end)
