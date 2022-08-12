local logger = M("logger");
local utils = M("utils");
local callback = M("callback");
local event = M("event");
local game = M("game");
local characterClass = M("character");

local users = {};

local Create = function(identifier)
    local id = MySQL.insert.await("INSERT INTO users (identifier) VALUES (?)", {identifier});
	local user = module.getById(id);

	return user;
end

local Construct = function(id)
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
		return self.currentCharacterId;
	end;
	table.insert(self.rpcWhitelist, "setCurrentCharacterId")

	self.setCurrentCharacterId = function(id)
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
		local ids = user.getCharacterIds();	
	
		local characters = {};
		for k,v in pairs(results) do
			local character = module.getById(v.id);
			table.insert(characters, character);
		end
		return characters;
	end;

	return self;
end;

module.getById = function(id)
	if not users[id] then
		users[id] = Construct(id);
	end

	return users[id];
end;

module.getByIdentifier = function(identifier)
	local id = MySQL.scalar.await("SELECT id FROM users WHERE identifier=?", {identifier});
	
	if id then
		return module.getById(id);
	else
		local user = Create(identifier);
		users[user.id] = user;
		return user;
	end
end;

module.getByPlayerId = function(playerId)
	local identifier = utils.getIdentifier(playerId);
	return module.getByIdentifier(identifier);
end;

callback.register("user:rpc", function(playerId, cb, name, ...)
	local user = module.getByPlayerId(playerId);
	
	if not utils.table.contains(user.rpcWhitelist, name) then
		logger.warn("function name " .. name .. " not in whitelist - user rpc failed.");
		return;
	end

	cb(user[name](...));
end);
