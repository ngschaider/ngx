local utils = M("utils");
local callback = M("callback");
local userClass = M("user");
local event = M("event");
local logger = M("logger");

local characters = {};

local Create = function(userId, firstname, lastname, dateofbirth, height)
	local id = MySQL.insert.await("INSERT INTO characters (user_id, firstname, lastname, dateofbirth, height, position_x, position_y, position_z) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {
		userId, firstname, lastname, dateofbirth, height, 213.78, -900.12, 30.69
	});
	local character = module.getById(id);
	event.emit("character:create:after", character);

	return character;
end;

local Construct = function(id)
	local self = {};

	self.id = tonumber(id);
	self.rpcWhitelist = {"getId", "getName", "getLastPosition", "getUserId", "getHeight", "getDateOfBirth"};

	self.getId = function()
		return self.id;
	end;

	self.getUserId = function()
		local userId = MySQL.scalar.await("SELECT user_id FROM characters WHERE id=?", {self.id});
		return tonumber(userId);
	end;

	self.getUser = function()
		local userId = self.getUserId();
		return userClass.getById(userId);
	end;

	self.setPosition = function(coords)
		self.getUser().emit("utils:teleport", coords);
	end;

	self.getLastPosition = function()
		local results = MySQL.single.await("SELECT position_x, position_y, position_z FROM characters WHERE id=?", {self.id});
		return {
			x = results.position_x,
			y = results.position_y,
			z = results.position_z
		};
	end;
	
	self.getName = function()
		local result = MySQL.single.await("SELECT firstname, lastname FROM characters WHERE id=?", {self.id});
		return result.firstname .. " " .. result.lastname;
	end;

	self.getHeight = function()
		local height = MySQL.scalar.await("SELECT height FROM characters WHERE id=?", {self.id});
		return height;
	end;

	self.getDateOfBirth = function()
		local dateOfBirth = MySQL.scalar.await("SELECT dateofbirth FROM characters WHERE id=?", {self.id});
		return dateOfBirth;
	end;

	event.emit("character:construct:after", self);

	return self;
end

event.on("user:construct:after", function(user)
	user.getLastCharacter = function()
		local characterId = MySQL.scalar.await("SELECT last_character_id FROM users WHERE id=?", {user.id});

		return characterClass.getById(characterId);
	end;
	table.insert(user.rpcWhitelist, "getLastCharacter")

	user.setCurrentCharacter = function(id)
		user.currentCharacter = module.getById(id);
		MySQL.update.await("UPDATE users SET last_character_id=? WHERE id=?", {id, user.id});
	end;
	table.insert(user.rpcWhitelist, "setLastCharacter")
	
	user.getCurrentCharacter = function()
		return user.currentCharacter;
	end;

	user.setCurrentCharacter = function(id)
		user.currentCharacter = module.getById(id);
	end;
	table.insert(user.rpcWhitelist, "setCurrentCharacter")

	user.createCharacter = function(firstname, lastname, dateofbirth, height)
		local character = Create(user.id, firstname, lastname, dateofbirth, height);
		user.setCurrentCharacter(character.id);
	end;
	table.insert(user.rpcWhitelist, "createCharacter");

	user.getCharacterIds = function()
		local results = MySQL.query.await("SELECT id FROM characters WHERE user_id=?", {user.id});
		
		local ids = {};
		for k,v in pairs(results) do
			table.insert(ids, v.id);
		end
		return ids;
	end;
	table.insert(user.rpcWhitelist, "getCharacterIds");

	user.getCharacters = function()
		local ids = user.getCharacterIds();	
	
		local characters = {};
		for k,v in pairs(results) do
			local character = module.getById(v.id);
			table.insert(characters, character);
		end
		return characters;
	end;
end);

module.getById = function(id)
	if not characters[id] then
		characters[id] = Construct(id);
	end

	return characters[id];
end;

module.getByPlayerId = function(playerId)
	local user = userClass.getByPlayerId(playerId);
	
	if not user then
		logger.debug("User with player id " .. playerId .. " not found - returning nil");
		return nil;
	end

	return user.getCurrentCharacter();
end;

callback.register("character:rpc", function(playerId, cb, id, name, ...)
	local character = module.getById(id);

	if not character then
		logger.warn("Character not found - rpc failed");
		return;
	end

	if character.getUser().getPlayerId() ~= playerId then
		logger.warn("Character not owned by requester - rpc failed");
		return;
	end	

	if not utils.table.contains(character.rpcWhitelist, name) then
		logger.warn("Requested character rpc " .. name .. " not whitelisted - skipping");
		return;
	end

	cb(character[name](...));
end);

