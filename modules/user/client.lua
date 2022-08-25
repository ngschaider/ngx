local callback = M("callback");
local Character = M("character");
local class = M("class");

local User = class("User");

User.static.GetSelf = function()
	local p = promise.new();
	callback.trigger("user:getSelfId", function(id)
		p:resolve(id);
	end);
	local id = Citizen.Await(p);
	return User.GetById(id);
end;

User.static.GetAllOnline = function(cb)
	local p = promise.new();
	callback.trigger("user:getAllOnlineIds", function(ids)
		p:resolve(ids);
	end);
	local ids = Citizen.Await(p);

	local users = {};
	for _,id in pairs(ids) do
		local user = User.GetById(id);
		table.insert(users, user);
	end

	return users;
end;

function User:initialize(id)
	self.id = id;
end

function User:_rpc(name, ...)
	local p = promise.new();
	callback.trigger("item:rpc", function(...) 
		p:resolve(...);
	end, self.id, name, ...);
	return Citizen.Await(p);
end;

function User:getName()
	return self._rpc("getName");
end;

function User:getCharacterIds()
	return self._rpc("getCharacterIds")
end;

function User:getCharacters()
	local ids = self.getCharacterIds();
	local characters = {};
	for _,id in pairs(ids) do
		local character = Character.getById(id);
		table.insert(characters, character);
	end
	return characters;
end;

function User:setCurrentCharacterId(id)
	self._rpc("setCurrentCharacterId", id);
end;

function User:getCurrentCharacterId()
	return self._rpc("getCurrentCharacterId");
end;

function User:getCurrentCharacter()
	local currentCharacterId = self.getCurrentCharacterId();
	if currentCharacterId then
		return Character.GetById(currentCharacterId);
	else
		return nil;
	end
end;

function User:createCharacter(firstname, lastname, dateofbirth, height, skin)
	local id = self._rpc("createCharacter", firstname, lastname, dateofbirth, height, skin);
	return Character.GetById(id);
end;


module = User;