local callback = M("core").callback;
local Character = M("character");
local class = M("class");
local utils = M("utils");
local core = M("core");
local logger = M("core").logger;

local User = class("User", core.SyncObject);
core.RegisterSyncClass(User);

function User:initialize(id)
	core.SyncObject.initialize(self, "User", id, "users");
	logger.debug("user", "initialize", "id", id);
	logger.debug("user", "initialize", "self._data", json.encode(self._data));
end

function User:getIdentifier()
	return self:getData("identifier");
end

function User:getName()
	return self:rpc("getName");
end;

function User:getCharacterIds()
	return self:rpc("getCharacterIds")
end;

function User:getCharacters()
	local ids = self:getCharacterIds();
	local characters = utils.table.mapValues(ids, function(id)
		return Character.GetById(id);
	end);
	return characters;
end;

function User:getCurrentCharacterId()
	local id = self:getData("currentCharacterId");
	logger.debug("user", "getCurrentCharacterId", "id", id);
	return id;
end;

function User:setCurrentCharacterId(id)
	logger.debug("user", "setCurrentCharacterId", "id", id);
	self:setData("currentCharacterId", id);
end;

function User:getCurrentCharacter()
	local id = self:getCurrentCharacterId();
	logger.debug("user", "getCurrentCharacter", "id", id);
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
	local id = callback.trigger("user:getSelfId");
	local user = module.GetById(id);
	
	return user;
end;

module.GetOnline = function()
	local ids = callback.trigger("user:getOnlineIds");

	local users = utils.table.mapValues(ids, function(id)
		return module.GetById(id);
	end);

	return users;
end;