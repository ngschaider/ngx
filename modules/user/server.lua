local logger = M("core").logger;
local utils = M("utils");
local callback = M("core").callback;
local event = M("core").event;
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

function User:emitClient(name, ...)
	event.emitClient(name, self:getPlayerId(), ...);
end

function User:getPlayerId()
	for _,v in pairs(GetPlayers()) do
		if utils.getIdentifier(v) == self.identifier then
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
	return self.identifier;
end

function User:showNotification(msg)
	self:emitClient("notification:showNotification", msg);
end

function User:showHelpNotification(msg, thisFrame, beep, duration)
	self:emitClient("notification:showHelpNotification", msg, thisFrame, beep, duration);
end

function User:setCurrentCharacterId(id)
	self:setData("currentCharacterId", id);
	logger.debug("User:setCurrentCharacterId", "id", id);
end

function User:getCurrentCharacterId()
	local id = self:getData("currentCharacterId")
	logger.debug("User:getCurrentCharacterId", "id", id);
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
	local ids = utils.table.map(results, function(v)
		return v.id;
	end);
	return ids;
end

function User:getCharacters()
	local ids = self:getCharacterIds();

	local characters = utils.table.map(ids, function(id)
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
	logger.debug("User:GetByIdentifier", "identifier", identifier);
	local id = MySQL.scalar.await("SELECT id FROM users WHERE identifier=?", {identifier});
	logger.debug("User:GetByIdentifier", "id", id);

	if id then
		return module.GetById(id);
	else
		local user = module.Create(identifier);
		return user;
	end
end;


module.GetByPlayerId = function(playerId)
	logger.debug("User:GetByPlayerId", "playerId", playerId);
	local identifier = utils.getIdentifier(playerId);
	logger.debug("module.GetByPlayerId", "identifier", identifier);
	local user = module.GetByIdentifier(identifier);
	logger.debug("module.GetByPlayerId", "user.id", user.id);
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

callback.register("user:getSelfId", function(playerId, cb)
	logger.debug("callback called", playerId, cb);
	local user = module.GetByPlayerId(playerId);
	logger.debug("calling cb");
	cb(user.id);
end);

callback.register("user:getOnlineIds", function(playerId, cb)
	local ids = module.GetOnlineIds();
	cb(ids);
end);