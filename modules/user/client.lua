local callback = M("core").callback;
local Character = M("character");
local class = M("class");
local utils = M("utils");
local core = M("core");
local logger = M("logger");

local User = class("User", core.SyncObject);
core.RegisterSyncClass(User);

function User:initialize(id)
	core.SyncObject.initialize(self, "User", id, "users");
	logger.debug("User.initialize", "id", id);
	logger.debug("User.initialize", "self._data", json.encode(self._data));
end

function User:getName()
	return self:rpc("getName");
end;

function User:getCharacterIds()
	return self:rpc("getCharacterIds")
end;

function User:getCharacters()
	local ids = self:getCharacterIds();
	local characters = utils.table.map(ids, function(id)
		return Character.GetById(id);
	end);
	return characters;
end;

function User:getCurrentCharacterId()
	local id = self:getData("currentCharacterId");
	logger.debug("User:getCurrentCharacterId", "id", id);
	return id;
end;

function User:setCurrentCharacterId(id)
	logger.debug("User:setCurrentCharacterId", "id", id);
	self:setData("currentCharacterId", id);
end;

function User:getCurrentCharacter()
	local id = self:getCurrentCharacterId();
	logger.debug("User:getCurrentCharacter", "id", id);
	if id then
		return Character.GetById(id);
	else
		return nil;
	end
end;

function User:createCharacter(firstname, lastname, dateofbirth, skin)
	local id = self:rpc("createCharacter", firstname, lastname, dateofbirth, skin);
	return Character.GetById(id);
end;

module.GetById = function(id)
	return core.GetSyncObject("User", id);
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