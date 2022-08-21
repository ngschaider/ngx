local callback = M("callback");
local utils = M("utils");
local logger = M("logger");
local event = M("event");
local skin = M("skin");

local characters = {};

local Construct = function(id)
	local self = {};

	local rpc = function(name, cb, ...)
		callback.trigger("character:rpc", cb, self.id, name, ...);
	end;

	self.id = id;

	self.getName = function(cb)
		local p = promise.new();
		rpc("getName", function(name)
			p:resolve(name);
		end);
		return Citizen.Await(p);
	end;

	self.getLastPosition = function(cb)
		local p = promise.new()
		rpc("getLastPosition", function(lastPosition)
			p:resolve(lastPosition)
		end);
		return Citizen.Await(p);
	end;

	self.getSkin = function(cb)
		local p = promise.new();
		rpc("getSkin", function(skin)
			p:resolve(skin);
		end);
		return Citizen.Await(p);
	end;
	
	self.setSkin = function(skin, cb)
		local p = promise.new();
		rpc("setSkin", function()
			p:resolve();
		end, skin);
		return Citizen.Await(p);
	end;

	return self;
end;

module.getById = function(id)
	if not characters[id] then
		characters[id] = Construct(id);
	end

	return characters[id];
end;