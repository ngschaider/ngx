local utils = M("utils");
local callback = M("callback");
local logger = M("logger");
local Inventory = M("inventory");
local class = M("class");

local Character = class("Character");

Character.static.rpcWhitelist = {};

function Character:initialize(id)
	self.id = id;
	self._data = MySQL.single.await("SELECT * FROM characters WHERE id=?", {self.id});
end

function Character:getId()
	return self.id;
end 
table.insert(Character.static.rpcWhitelist, "getId");

function Character:getUserId()
	return self._data.user_id;
end
table.insert(Character.static.rpcWhitelist, "getUserId");

function Character:getUser()
	local userId = self:getUserId();
	return M("user").GetById(userId);
end

function Character:setPosition(coords)
	utils.teleport(coords);
end;

function Character:getPosition()
	local playerId = self:getUser():getPlayerId();
	local ped = GetPlayerPed(playerId);
	return GetEntityCoords(ped);
end

function Character:getLastPosition()
	return {
		x = tonumber(self._data.position_x),
		y = tonumber(self._data.position_y),
		z = tonumber(self._data.position_z),
	};
end
table.insert(Character.static.rpcWhitelist, "getLastPosition");

function Character:getName()
	return self._data.firstname .. " " .. self._data.lastname;
end
table.insert(Character.static.rpcWhitelist, "getName");

function Character:getDateOfBirth()
	return self._data.dateOfBirth;
end
table.insert(Character.static.rpcWhitelist, "getDateOfBirth");

function Character:getSkin()
	return json.decode(self._data.skin);
end
table.insert(Character.static.rpcWhitelist, "getSkin");

function Character:setSkin(skin)
	local skinStr = json.encode(skin);
	MySQL.update.await("UPDATE characters SET skin=? WHERE id=?", {skinStr, self.id});
	self._data.skin = skinStr;
end
table.insert(Character.static.rpcWhitelist, "setSkin");

function Character:getInventoryId()
	logger.debug("Character:getInventory", "self.id", self.id);
	local inventoryId = self._data.inventory_id;
	logger.debug("Character:getInventory", "inventoryId", inventoryId);
	return inventoryId;
end
table.insert(Character.static.rpcWhitelist, "getInventoryId");

function Character:getInventory()
	local inventoryId = self:getInventoryId();
	return Inventory.GetById(inventoryId);
end

local cache = {};
module.GetById = function(id)
	if not cache[id] then
		cache[id] = Character:new(id);
	end

	return cache[id];
end

module.Create = function(userId, firstname, lastname, dateOfBirth, skin)
	local inventoryId = Inventory.Create(20);

	local skinStr = json.encode(skin);
	local id = MySQL.insert.await("INSERT INTO characters (user_id, firstname, lastname, date_of_birth, skin, position_x, position_y, position_z, inventory_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {
		userId, 
		firstname, 
		lastname, 
		dateOfBirth,
		skinStr, 
		213.78, 
		-900.12, 
		29.69,
		inventoryId,
	});

	return module.GetById(id);
end;

module.GetByPlayerId = function(playerId)
	local user = M("user").GetByPlayerId(playerId);

	if not user then
		logger.error("User with player id " .. playerId .. " not found - returning nil");
		return nil;
	end

	print("Character.static:GetByPlayerId", "user.id", user.id)
	return user:getCurrentCharacter();
end

module.GetAll = function()
	local results = MySQL.query.await("SELECT id FROM characters");

	local characters = utils.table.map(results, function(v)
		return module.GetById(v.id);
	end)
	return characters;
end



callback.register("character:rpc", function(playerId, cb, id, name, ...)
	local character = module.GetById(id);

	logger.debug("event - character:rpc", "id", id);
	if not character then
		logger.warn("Character not found - rpc failed");
		return;
	end

	if not utils.table.contains(Character.rpcWhitelist, name) then
		logger.warn("Requested character rpc " .. name .. " not whitelisted - rpc failed");
		return;
	end

	-- we have to pass the character object because we are not using the colon syntax like character:getName(...)
	cb(character[name](character, ...));
end);