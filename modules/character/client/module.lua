local callback = M("callback");
local user = M("user");
local utils = M("utils");
local logger = M("logger");
local event = M("event");

user.getCharacters = function(cb)
    user.rpc("getCharacterIds", function(ids)
		local ret = {};
		for _,id in pairs(ids) do
			local character = module.getById(id);
			table.insert(ret, character);
		end
		cb(ret);
	end);
end;

user.setLastCharacter = function(id, cb)
	user.rpc("setLastCharacter", cb, id);
end;

user.setCurrentCharacter = function(id, cb)
	user.rpc("setCurrentCharacter", cb, id);
end;

user.getCurrentCharacter = function(cb)
	user.rpc("getCurrentCharacter", cb);
end;

user.getLastCharacter = function(cb)
	user.rpc("getLastCharacter", cb);
end;

user.createCharacter = function(firstname, lastname, dateofbirth, height, skin, cb)
	user.rpc("createCharacter", function(id)
		local character = module.getById(id);
		cb(character);
	end, firstname, lastname, dateofbirth, height, skin);
end;

local characters = {};

local Construct = function(id)
	local self = {};

	self.id = id;

	self.getUser = function(cb)
		self.rpc("getUserId", function(id)
			return user.getById(id);
		end);
	end;

	self.rpc = function(name, cb, ...)
		callback.trigger("character:rpc", cb, self.id, name, ...);
	end;

	self.getName = function(cb)
		self.rpc("getName", cb);
	end;

	self.getLastPosition = function(cb)
		self.rpc("getLastPosition", cb);
	end;

	event.emit("character:construct:after", self);

	return self;
end;

-- this can possibly return nil;
module.getById = function(id)
	if not characters[id] then
		characters[id] = Construct(id);
	end

	return characters[id];
end;