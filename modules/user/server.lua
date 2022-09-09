local logger = M("core").logger;
local utils = M("utils");
local callback = M("core").callback;
local net = M("core").net;
local Character = M("character");
local class = M("class");
local core = M("core");

local User = class("User", core.SyncObject);
core.RegisterSyncClass(User);

function User:initialize(id)
	core.SyncObject.initialize(self, "User", id, "users");

	self:rpcMethod("getName", true);
	self:rpcMethod("createCharacter", true);
	self:rpcMethod("getCharacterIds", true);
	self:syncProperty("currentCharacterId", true, true);
end

function User:getPlayerId()
	for _,v in pairs(GetPlayers()) do
		local identifier = utils.getIdentifier(v);
		logger.debug("User:getPlayerId", "v", v);
		logger.debug("User:getPlayerId", "identifier", identifier);
		logger.debug("User:getPlayerId", "self:getIdentifier", self:getIdentifier());
		if identifier == self:getIdentifier() then
			return tonumber(v);
		end
	end

	return nil;
end

function User:getName()
	return GetPlayerName(self:getPlayerId());
end

function User:getIsOnline()
	return self:getPlayerId() ~= nil;
end

function User:kick(reason)
	if not self:getIsOnline() then
		return;
	end
	DropPlayer(self:getPlayerId(), reason);
end

function User:getIdentifier()
	return self:getData("identifier");
end

function User:setCurrentCharacterId(id)
	self:setData("currentCharacterId", id);
	logger.debug("user", "setCurrentCharacterId", "id", id);
end

function User:getCurrentCharacterId()
	local id = self:getData("currentCharacterId")
	logger.debug("user", "getCurrentCharacterId", "id", id);
	return id;
end

function User:getCurrentCharacter()
	local id = self:getCurrentCharacterId();
	return Character.GetById(id);
end

function User:createCharacter(firstname, lastname, dateOfBirth, skin)
	local id = Character.Create(self.id, firstname, lastname, dateOfBirth, skin);
	return Character.GetById(id);
end

function User:getCharacterIds()
	local results = MySQL.query.await("SELECT id FROM characters WHERE userId=?", {self.id});
	local ids = utils.table.mapValues(results, function(v)
		return v.id;
	end);
	return ids;
end

function User:getCharacters()
	local ids = self:getCharacterIds();

	local characters = utils.table.mapValues(ids, function(id)
		return Character.GetById(id);
	end);
	
	return characters;
end

module.GetById = function(id)
	return core.GetSyncObject("User", id);
end;

module.Create = function(identifier)
    local id = MySQL.insert.await("INSERT INTO users (identifier) VALUES (?)", {identifier});

	return module.GetById(id);
end;

module.GetByIdentifier = function(identifier)
	logger.debug("user", "GetByIdentifier", "identifier", identifier);
	local id = MySQL.scalar.await("SELECT id FROM users WHERE identifier=?", {identifier});
	logger.debug("user", "GetByIdentifier", "id", id);

	if id then
		return module.GetById(id);
	else
		local user = module.Create(identifier);
		return user;
	end
end;


module.GetByPlayerId = function(playerId)
	logger.debug("user", "module.GetByPlayerId", "playerId", playerId);
	local identifier = utils.getIdentifier(playerId);
	logger.debug("user", "module.GetByPlayerId", "identifier", identifier);
	local user = module.GetByIdentifier(identifier);
	logger.debug("user", "module.GetByPlayerId", "user.id", user.id);
	return user;
end;

module.GetAllOnline = function()
	local playerIds = GetPlayers();
	local users = {};
	for _,playerId in pairs(playerIds) do
		local user = User:GetByPlayerId(playerId);
		table.insert(users, user);
	end

	return users;
end;

module.GetOnlineIds = function()
	local users = module.GetAllOnline();
	local ids = {};
	for _,user in pairs(users) do
		table.insert(ids, user.id);
	end
	return ids;
end;

callback.register("user:getSelfId", function(user, cb)
	logger.debug("user", "user:getSelfId", user.id, cb);
	cb(user.id);
end);

callback.register("user:getOnlineIds", function(user, cb)
	local ids = module.GetOnlineIds();
	cb(ids);
end);