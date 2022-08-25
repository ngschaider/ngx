local logger = M("logger");
local utils = M("utils");
local callback = M("callback");
local event = M("event");
local game = M("game");
local Character = M("character");
local class = M("class");

local cachedUsers = {};

local User = class("User");


User.static.rpcWhitelist = {};

function User.static:Create(identifier)
    local id = MySQL.insert.await("INSERT INTO users (identifier) VALUES (?)", {identifier});
	local user = User:new(id);

	return user;
end;

function User.static:GetByIdentifier(identifier)
	logger.debug("User:GetByIdentifier", "identifier", identifier);
	local id = MySQL.scalar.await("SELECT id FROM users WHERE identifier=?", {identifier});
	logger.debug("User:GetByIdentifier", "id", id);

	if id then
		return User:new(id);
	else
		local user = User:Create(identifier);
		return user;
	end
end;

function User.static:GetByPlayerId(playerId)
	logger.debug("User:GetByPlayerId", "playerId", playerId);
	local identifier = utils.getIdentifier(playerId);
	logger.debug("User:GetByPlayerId", "identifier", identifier);
	local user = User:GetByIdentifier(identifier);
	logger.debug("User:GetByPlayerId", "user.id", user.id);
	return user;
end;

function User.static:GetAllOnlineIds()
	local users = User:GetAllOnline();
	local ids = {};
	for _,user in pairs(users) do
		table.insert(ids, user.id);
	end
	return ids;
end;

function User.static:GetAllOnline()
	local playerIds = GetPlayers();
	local users = {};
	for _,playerId in pairs(playerIds) do
		local user = User:GetByPlayerId(playerId);
		table.insert(users, user);
	end

	return users;
end;

function User:initialize(id)
	self.id = id;
	self.identifier = MySQL.scalar.await("SELECT identifier FROM users WHERE id=?", {self.id});

	-- copy over all non-database values from the cached object
	if cachedUsers[id] then
		self.currentCharacterId = cachedUsers[id].currentCharacterId;
	end
	cachedUsers[id] = self;
end

function User:emit(name, ...)
	event.emitClient(name, self:getPlayerId(), ...);
end;

function User:getPlayerId()
	for k,v in pairs(GetPlayers()) do
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

function User:getIsAdmin()
	return self.identifier == "5a66a5adef9f075731fd4306e231aa6d536dc094";
end;

function User:getIsOnline()
	return self:getPlayerId() ~= nil;
end;

function User:kick(reason)
	if not self:getIsOnline() then 
		return 
	end
	DropPlayer(self.playerId, reason);
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
	return Character:new(id);
end;

function User:createCharacter(firstname, lastname, dateOfBirth, skin)
	local characterId = Character:Create(self.id, firstname, lastname, dateOfBirth, skin);
	return Character:new(characterId);
end;
table.insert(User.static.rpcWhitelist, "createCharacter");

function User:getCharacterIds()
	local results = MySQL.query.await("SELECT id FROM characters WHERE user_id=?", {self.id});
	
	local ids = {};
	for _,v in pairs(results) do
		table.insert(ids, v.id);
	end
	return ids;
end;
table.insert(User.static.rpcWhitelist, "getCharacterIds");

function User:getCharacters()
	local ids = self:getCharacterIds();

	local characters = {};
	for _,id in pairs(ids) do
		local character = User:new(id);
		table.insert(characters, character);
	end
	return characters;
end;


callback.register("user:getAllOnlineIds", function(playerId, cb)
	local ids = User:GetAllOnlineIds();
	cb(ids);
end);

callback.register("user:rpc", function(playerId, cb, userId, name, ...)
	print(userId);
	local user = User:new(userId);

	if not utils.table.contains(User.rpcWhitelist, name) then
		logger.warn("function name " .. name .. " not in whitelist - user rpc failed.");
		return;
	end

	-- we have to pass the user object because we are not using the colon syntax like user:getCharacterIds(...)
	cb(user[name](user, ...));
end);

callback.register("user:getSelfId", function(playerId, cb)
	print("callback called", playerId, cb);
	local user = User:GetByPlayerId(playerId);
	print("calling cb");
	cb(user.id);
end);


module = User;