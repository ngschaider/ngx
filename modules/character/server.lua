local utils = M("utils");
local callback = M("callback");
local logger = M("logger");
local Inventory = M("inventory");
local class = M("class");

local Character = class("Character");

Character.static.rpcWhitelist = {};

function Character.static:Create(userId, firstname, lastname, dateOfBirth, skin)
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

	return Character:new(id);
end;

function Character.static:GetByPlayerId(playerId)
	local user = M("user"):GetByPlayerId(playerId);

	if not user then
		logger.error("User with player id " .. playerId .. " not found - returning nil");
		return nil;
	end

	print("Character.static:GetByPlayerId", "user.id", user.id)
	return user:getCurrentCharacter();
end

function Character.static:GetAll()
	local characters = {};

	local data = MySQL.query.await("SELECT id FROM characters");
	for _,v in pairs(data) do
		local character = Character:new(v.id);
		table.insert(characters, character);
	end

	return characters;
end

function Character:initialize(id)
	self.id = id;
end

function Character:getId()
	return self.id;
end 
table.insert(Character.static.rpcWhitelist, "getId");

function Character:getUserId()
	local userId = MySQL.scalar.await("SELECT user_id FROM characters WHERE id=?", {self.id});
	return tonumber(userId);
end
table.insert(Character.static.rpcWhitelist, "getUserId");

function Character:getUser()
	local userId = self:getUserId();
	return M("user"):new(userId);
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
	local results = MySQL.single.await("SELECT position_x, position_y, position_z FROM characters WHERE id=?", {self.id});
	return {
		x = tonumber(results.position_x), 
		y = tonumber(results.position_y), 
		z = tonumber(results.position_z),
	};
end
table.insert(Character.static.rpcWhitelist, "getLastPosition");

function Character:getName()
	local result = MySQL.single.await("SELECT firstname, lastname FROM characters WHERE id=?", {self.id});
	return result.firstname .. " " .. result.lastname;
end
table.insert(Character.static.rpcWhitelist, "getName");

function Character:getDateOfBirth()
	local dateOfBirth = MySQL.scalar.await("SELECT date_of_birth FROM characters WHERE id=?", {self.id});
	return dateOfBirth;
end
table.insert(Character.static.rpcWhitelist, "getDateOfBirth");

function Character:getSkin()
	local skinStr = MySQL.scalar.await("SELECT skin FROM characters WHERE id=?", {self.id});
	print(skinStr);
	return json.decode(skinStr);
end
table.insert(Character.static.rpcWhitelist, "getSkin");

function Character:setSkin(skin)
	local skinStr = json.encode(skin);
	MySQL.update.await("UPDATE characters SET skin=? WHERE id=?", {skinStr, self.id});
end
table.insert(Character.static.rpcWhitelist, "setSkin");

function Character:getInventoryId()
	logger.debug("Character:getInventory", "self.id", self.id);
	local inventoryId = MySQL.scalar.await("SELECT inventory_id FROM characters WHERE id=?", {self.id});
	logger.debug("Character:getInventory", "inventoryId", inventoryId);
	return inventoryId;
end
table.insert(Character.static.rpcWhitelist, "getInventoryId");

function Character:getInventory()
	local inventoryId = self:getInventoryId();
	return Inventory:new(inventoryId);
end

callback.register("character:rpc", function(playerId, cb, id, name, ...)
	local character = Character:new(id);

	if not character then
		logger.warn("Character not found - rpc failed");
		return;
	end

	if character:getUser():getPlayerId() ~= playerId and not character:getUser():getIsAdmin() then
		logger.warn("Character not owned by requester - rpc failed");
		return;
	end	

	if not utils.table.contains(Character.rpcWhitelist, name) then
		logger.warn("Requested character rpc " .. name .. " not whitelisted - rpc failed");
		return;
	end

	-- we have to pass the character object because we are not using the colon syntax like character:getName(...)
	cb(character[name](character, ...));
end);


module = Character;