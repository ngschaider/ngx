local net = module.net;
local logger = module.logger;

local serverCallbacks = {};
local lastRequestId = 0;

local GetAndConsumeRequestId = function()
    lastRequestId = lastRequestId + 1;
    return lastRequestId;
end;

module.callback = {};

module.callback.trigger = function(name, ...)
	logger.debug("core->callback", "triggered C->S->C callback " .. name);

    local requestId = GetAndConsumeRequestId();

	local p = promise.new();
	serverCallbacks[requestId] = function(...)
		p:resolve(...);
	end;

	net.send("core:callback:request", name, requestId, ...);

	return Citizen.Await(p);
end;

net.on("core:callback:response", function(requestId, ...)
	-- developer does not need to provide a callback function when triggering a callback
	if serverCallbacks[requestId] then
		serverCallbacks[requestId](...);
		serverCallbacks[requestId] = nil;
	end
end);


local clientCallbacks = {};

module.callback.register = function(name, cb)
	logger.debug("core->callback", "module.callback.register", "name", name);
    clientCallbacks[name] = cb;
end;

net.on("core:callback:request", function(name, requestId, ...)
	if clientCallbacks[name] then
		clientCallbacks[name](function(...)
			net.send("core:callback:response", requestId, ...);
		end, ...);
	else
		logger.warn("core->callback", "S->C->S callback " .. name .. " not found.");
	end
end);