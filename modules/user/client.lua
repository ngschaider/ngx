local callback = M("callback");
local Character = M("character");
local class = M("class");
local utils = M("utils");

local User = class("User");

function User:initialize(id)
	print("User.initialize", "id", id);
	self.id = id;
end

function User:_rpc(name, ...)
	print("User:rpc", name, self.id);
	local p = promise.new();
	callback.trigger("user:rpc", function(...)
		p:resolve(...);
	end, self.id, name, ...);
	return Citizen.Await(p);
end;

function User:getName()
	return self:_rpc("getName");
end;

function User:getCharacterIds()
	return self:_rpc("getCharacterIds")
end;

function User:getCharacters()
	local ids = self:getCharacterIds();
	local characters = utils.table.map(ids, function(id)
		return Character.GetById(id);
	end);
	return characters;
end;

function User:setCurrentCharacterId(id)
	self:_rpc("setCurrentCharacterId", id);
end;

function User:getCurrentCharacterId()
	return self:_rpc("getCurrentCharacterId");
end;

function User:getCurrentCharacter()
	local currentCharacterId = self:getCurrentCharacterId();
	if currentCharacterId then
		return Character.GetById(currentCharacterId);
	else
		return nil;
	end
end;

function User:createCharacter(firstname, lastname, dateofbirth, skin)
	local id = self:_rpc("createCharacter", firstname, lastname, dateofbirth, skin);
	return Character.GetById(id);
end;



module.GetById = function(id)
	return User:new(id);
end;

module.GetSelf = function()
	local p = promise.new();
	callback.trigger("user:getSelfId", function(id)
		p:resolve(id);
	end);
	local id = Citizen.Await(p);
	local user = module.GetById(id);
	return user;
end;

module.GetOnline = function()
	local p = promise.new();
	callback.trigger("user:getOnlineIds", function(ids)
		p:resolve(ids);
	end);
	local ids = Citizen.Await(p);

	local users = {};
	for _,id in pairs(ids) do
		local user = module.GetById(id);
		table.insert(users, user);
	end

	return users;
end;