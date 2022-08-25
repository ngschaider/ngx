local logger = M("logger");
local utils = M("utils");
local callback = M("callback");
local event = M("event");
local game = M("game");
local Character = M("character");
local class = M("class");

local User = class("User");

User.static.rpcWhitelist = {};

Character.static.Create = function(identifier)
    local id = MySQL.insert.await("INSERT INTO users (identifier) VALUES (?)", {identifier});
	local user = User.GetById(id);

	return user;
end;

User.static.GetByIdentifier = function(identifier)
	--logger.debug("user.getByIdentifier", "identifier", identifier);
	local id = MySQL.scalar.await("SELECT id FROM users WHERE identifier=?", {identifier});
	--logger.debug("user.getByIdentifier", "id", id);

	if id then
		return User.GetById(id);
	else
		local user = Create(identifier);
		users[user.id] = user;
		return user;
	end
end;

User.static.GetByPlayerId = function(playerId)
	--logger.debug("user.getByPlayerId", "playerId", playerId);
	local identifier = utils.getIdentifier(playerId);
	--logger.debug("user.getByPlayerId", "identifier", identifier);
	local user = User.GetByIdentifier(identifier);
	--logger.debug("user.getByPlayerId", "user.id", user.id);
	return user;
end;

User.static.GetAllOnlineIds = function()
	local users = User.GetAllOnline();
	local ids = {};
	for _,user in pairs(users) do
		table.insert(ids, user.id);
	end
	return ids;
end;

User.static.GetAllOnline = function()
	local playerIds = GetPlayers();
	local users = {};
	for _,playerId in pairs(playerIds) do
		local user = User.GetByPlayerId(playerId);
		table.insert(users, user);
	end

	return users;
end;
module.GetAllOnline = User.GetAllOnline;

function User:initialize(id)
	self.id = id;
	self.identifier = MySQL.scalar.await("SELECT identifier FROM users WHERE id=?", {self.id});
end

function User:emit(name, ...)
	event.emitClient(name, self.getPlayerId(), ...);
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
	return GetPlayerName(self.getPlayerId());
end;
table.insert(User.static.rpcWhitelist, "getName");

function User:getIsAdmin()
	return self.identifier == "5a66a5adef9f075731fd4306e231aa6d536dc094";
end;

function User:getIsOnline()
	return self.getPlayerId() ~= nil;
end;

function User:kick(reason)
	if not self.getIsOnline() then 
		return 
	end
	DropPlayer(self.playerId, reason);
end;

function User:getIdentifier()
	return self.identifier;
end;

function User:showNotification(msg)
	self.emit("notification:showNotification", msg);
end;

function User:showHelpNotification(msg, thisFrame, beep, duration)
	self.emit("notification:showHelpNotification", msg, thisFrame, beep, duration);
end;

function User:getCurrentCharacterId()
	print("getCurrentCharacterId", self.currentCharacterId);
	return self.currentCharacterId;
end;
table.insert(User.static.rpcWhitelist, "getCurrentCharacterId")

function User:setCurrentCharacterId(id)
	--print("setCurrentCharacterId", self.currentCharacterId);
	self.currentCharacterId = id;
end;
table.insert(User.static.rpcWhitelist, "setCurrentCharacterId")

function User:getCurrentCharacter()
	local id = self.getCurrentCharacterId();
	return Character.getById(id);
end;

function User:createCharacter(firstname, lastname, dateofbirth, height, skin)
	local characterId = Character.Create(self.id, firstname, lastname, dateofbirth, height, skin);
	return characterId;
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
	local ids = self.getCharacterIds();

	local characters = {};
	for _,id in pairs(ids) do
		local character = User.GetById(id);
		table.insert(characters, character);
	end
	return characters;
end;


callback.register("user:getAllOnlineIds", function(playerId, cb)
	local ids = User.GetAllOnlineIds();
	cb(ids);
end);

callback.register("user:rpc", function(playerId, cb, name, ...)
	local user = User.GetByPlayerId(playerId);

	if not utils.table.contains(user.rpcWhitelist, name) then
		logger.warn("function name " .. name .. " not in whitelist - user rpc failed.");
		return;
	end

	cb(user[name](...));
end);

callback.register("user:getSelfId", function(playerId, cb)
	--print("callback called", playerId, cb);
	local user = User.GetByPlayerId(playerId);
	--print("calling cb");
	cb(user.id);
end);