local logger = M("logger");
local utils = M("utils");
local callback = M("callback");
local event = M("event");
local game = M("game");
local Character = M("character");
local OOP = M("oop");


local Character = OOP.CreateClass("Character", function(id)
	local self = {};

	self.id = id;
	self.identifier = MySQL.scalar.await("SELECT identifier FROM users WHERE id=?", {self.id});

	if not self.identifier then
		return nil;
	end

	self.rpcWhitelist = {};

	self.emit = function(name, ...)
		event.emitClient(name, self.getPlayerId(), ...);
	end;

	self.getPlayerId = function()
		for k,v in pairs(GetPlayers()) do
			if utils.getIdentifier(v) == self.identifier then
				return tonumber(v);
			end
		end
		
		return nil;
	end;

	self.getName = function()
		return GetPlayerName(self.getPlayerId());
	end;
	table.insert(self.rpcWhitelist, "getName");

	self.getIsAdmin = function()
		return self.identifier == "5a66a5adef9f075731fd4306e231aa6d536dc094";
	end;

	self.getIsOnline = function()
		return self.getPlayerId() ~= nil;
	end;

	self.kick = function(reason)
		if not self.getIsOnline() then 
			return 
		end
		DropPlayer(self.playerId, reason);
	end;

	self.getIdentifier = function()
		return self.identifier;
	end;

	self.showNotification = function(msg)
		self.emit("notification:showNotification", msg);
	end;

	self.showHelpNotification = function(msg, thisFrame, beep, duration)
		self.emit("notification:showHelpNotification", msg, thisFrame, beep, duration);
	end;

	self.getCurrentCharacterId = function()
		print("getCurrentCharacterId", self.currentCharacterId);
		return self.currentCharacterId;
	end;
	table.insert(self.rpcWhitelist, "getCurrentCharacterId")

	self.setCurrentCharacterId = function(id)
		--print("setCurrentCharacterId", self.currentCharacterId);
		self.currentCharacterId = id;
	end;
	table.insert(self.rpcWhitelist, "setCurrentCharacterId")

	self.getCurrentCharacter = function()
		local id = self.getCurrentCharacterId();
		return characterClass.getById(id);
	end;

	self.createCharacter = function(firstname, lastname, dateofbirth, height, skin)
		local characterId = characterClass.Create(self.id, firstname, lastname, dateofbirth, height, skin);
		return characterId;
	end;
	table.insert(self.rpcWhitelist, "createCharacter");

	self.getCharacterIds = function()
		local results = MySQL.query.await("SELECT id FROM characters WHERE user_id=?", {self.id});
		
		local ids = {};
		for k,v in pairs(results) do
			table.insert(ids, v.id);
		end
		return ids;
	end;
	table.insert(self.rpcWhitelist, "getCharacterIds");

	self.getCharacters = function()
		local ids = self.getCharacterIds();	
	
		local characters = {};
		for k,v in pairs(results) do
			local character = User.GetById(v.id);
			table.insert(characters, character);
		end
		return characters;
	end;

	return self;
end);
module.GetById = User.constructor;

Character.Create = function(identifier)
    local id = MySQL.insert.await("INSERT INTO users (identifier) VALUES (?)", {identifier});
	local user = User.GetById(id);

	return user;
end
module.Create = User.Create;

User.GetByIdentifier = function(identifier)
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
module.GetByIdentifier = User.GetByIdentifier;

User.GetByPlayerId = function(playerId)
	--logger.debug("user.getByPlayerId", "playerId", playerId);
	local identifier = utils.getIdentifier(playerId);
	--logger.debug("user.getByPlayerId", "identifier", identifier);
	local user = User.GetByIdentifier(identifier);
	--logger.debug("user.getByPlayerId", "user.id", user.id);
	return user;
end;
module.GetByPlayerId = User.GetByPlayerId;

User.GetAllOnlineIds = function()
	local users = User.GetAllOnline();
	local ids = {};
	for _,user in pairs(users) do
		table.insert(ids, user.id);
	end
	return ids;
end;
module.GetAllOnlineIds = User.GetAllOnlineIds;

callback.register("user:getAllOnlineIds", function(playerId, cb)
	local ids = User.GetAllOnlineIds();
	cb(ids);
end);

User.GetAllOnline = function()
	local playerIds = GetPlayers();
	local users = {};
	for _,playerId in pairs(playerIds) do
		local user = User.GetByPlayerId(playerId);
		table.insert(users, user);
	end

	return users;
end;
module.GetAllOnline = User.GetAllOnline;

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