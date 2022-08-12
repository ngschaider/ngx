local utils = M("utils");
local callback = M("callback");
local userClass = M("user");
local event = M("event");
local logger = M("logger");

local characters = {};

module.Create = function(userId, firstname, lastname, dateofbirth, height, skin)
	local skinStr = json.encode(skin);
	print(skinStr);
	local id = MySQL.insert.await("INSERT INTO characters (user_id, firstname, lastname, dateofbirth, height, skin, position_x, position_y, position_z) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {
		userId, firstname, lastname, dateofbirth, height, skinStr, 213.78, -900.12, 29.69
	});

	return id;
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
			x = tonumber(results.position_x),
			y = tonumber(results.position_y),
			z = tonumber(results.position_z),
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

	self.getSkin = function()
        local skinStr = MySQL.scalar.await("SELECT skin FROM characters WHERE id=?", {self.id});
        return json.decode(skinStr);
    end;
    table.insert(self.rpcWhitelist, "getSkin");

    self.setSkin = function(skin)
        local skinStr = json.encode(skin);
        MySQL.update.await("UPDATE characters SET skin=? WHERE id=?", {skinStr, character.id});
    end;
    table.insert(self.rpcWhitelist, "setSkin");

	return self;
end

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

