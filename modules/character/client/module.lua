local callback = M("callback");
local utils = M("utils");
local logger = M("logger");
local event = M("event");

local characters = {};

local Construct = function(id)
	local skin = M("skin");

	local self = {};

	self.id = id;

	local rpc = function(name, cb, ...)
		callback.trigger("character:rpc", cb, self.id, name, ...);
	end;

	self.getName = function(cb)
		rpc("getName", cb);
	end;

	self.getLastPosition = function(cb)
		rpc("getLastPosition", cb);
	end;

	self.getSkin = function(cb)
		rpc("getSkin", cb);
	end;
	
	self.setSkin = function(skin, cb)
		rpc("setSkin", cb, skin);
	end;

	return self;
end;

-- this can possibly return nil
module.getById = function(id)
	if not characters[id] then
		characters[id] = Construct(id);
	end

	return characters[id];
end;