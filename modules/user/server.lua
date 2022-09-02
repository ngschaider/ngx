local logger = M("logger");
local utils = M("utils");
local callback = M("callback");
local event = M("event");
local Character = M("character");
local class = M("class");

local User = class("User");

User.static.rpcWhitelist = {};

function User:initialize(id)
	self.id = id;
	self.identifier = MySQL.scalar.await("SELECT identifier FROM users WHERE id=?", {self.id});
end

function User:emit(name, ...)
	event.emitClient(name, self:getPlayerId(), ...);
end;

function User:getPlayerId()
	for _,v in pairs(GetPlayers()) do
		if utils.getIdentifier(v) == self.identifier then
			return tonumber(v);
		end
	end
	
	return nil;
end;

function User:getName()
	return GetPlayerName(self:getPlayerId());
end;
table.insert(User.static.rpcWhitelist, "getName");

function User:getIsOnline()
	return self:getPlayerId() ~= nil;
end;

function User:kick(reason)
	if not self:getIsOnline() then
		return;
	end
	DropPlayer(self:getPlayerId(), reason);
end;

function User:getIdentifier()
	return self.identifier;
end;

function User:showNotification(msg)
	self:emit("notification:showNotification", msg);
end;

function User:showHelpNotification(msg, thisFrame, beep, duration)
	self:emit("notification:showHelpNotification", msg, thisFrame, beep, duration);
end;

function User:getCurrentCharacterId()
	print("User:getCurrentCharacterId", "self.currentCharacterId", self.currentCharacterId);
	return self.currentCharacterId;
end;
table.insert(User.static.rpcWhitelist, "getCurrentCharacterId")

function User:setCurrentCharacterId(id)
	print("User:setCurrentCharacterId", "id", id);
	self.currentCharacterId = id;
end;
table.insert(User.static.rpcWhitelist, "setCurrentCharacterId")

function User:getCurrentCharacter()
	local id = self:getCurrentCharacterId();
	return Character.GetById(id);
end;

function User:createCharacter(firstname, lastname, dateOfBirth, skin)
	local id = Character.Create(self.id, firstname, lastname, dateOfBirth, skin);
	return Character.GetById(id);
end;
table.insert(User.static.rpcWhitelist, "createCharacter");

function User:getCharacterIds()
	local results = MySQL.query.await("SELECT id FROM characters WHERE user_id=?", {self.id});
	local ids = utils.table.map(results, function(v)
		return v.id;
	end);
	return ids;
end;
table.insert(User.static.rpcWhitelist, "getCharacterIds");

function User:getCharacters()
	local ids = self:getCharacterIds();

	local characters = utils.table.map(ids, function(id)
		return Character.GetById(id);
	end);
	
	return characters;
end;

local cache = {};
module.GetById = function(id)
	if not cache[id] then
		cache[id] = User:new(id);
	end

	return cache[id];
end

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
	print("callback called", playerId, cb);
	local user = module.GetByPlayerId(playerId);
	print("calling cb");
	cb(user.id);
end);

callback.register("user:getOnlineIds", function(playerId, cb)
	local ids = module.GetOnlineIds();
	cb(ids);
end);

callback.register("user:rpc", function(playerId, cb, userId, name, ...)
	print(userId);
	local user = module.GetById(userId);

	if not utils.table.contains(User.rpcWhitelist, name) then
		logger.warn("function name " .. name .. " not in whitelist - user rpc failed.");
		return;
	end

	-- we have to pass the user object because we are not using the colon syntax like user:getCharacterIds(...)
	cb(user[name](user, ...));
end);