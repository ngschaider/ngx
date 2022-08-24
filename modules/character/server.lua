local utils = M("utils");
local callback = M("callback");
local event = M("event");
local logger = M("logger");
local inventoryClass = M("inventory");
local class = M("class");

local Character = class("Character");

Character.static.rpcWhitelist = {};

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
	local userId = self.getUserId();
	return M("user").getById(userId);
end

function Character:setPosition(coords)
	utils.teleport(coords);
end;

function Character:getPosition()
	local playerId = self.getUser().getPlayerId();
	local ped = GetPlayerPed(playerId);
	return GetEntityCoords(ped);
end

function Character:getLastPosition()
	local results = MySQL.single.await("SELECT position_x, position_y, position_z FROM characters WHERE id=?", {self.id});
	return vector3(results.position_x, results.position_y, results.position_z);
end
table.insert(Character.static.rpcWhitelist, "getLastPosition");

function Character:getName()
	local result = MySQL.single.await("SELECT firstname, lastname FROM characters WHERE id=?", {self.id});
	return result.firstname .. " " .. result.lastname;
end
table.insert(Character.static.rpcWhitelist, "getName");

function Character:getHeight()
	local height = MySQL.scalar.await("SELECT height FROM characters WHERE id=?", {self.id});
	return height;
end
table.insert(Character.static.rpcWhitelist, "getHeight");

function Character:getDateOfBirth()
	local dateOfBirth = MySQL.scalar.await("SELECT dateofbirth FROM characters WHERE id=?", {self.id});
	return dateOfBirth;
end
table.insert(Character.static.rpcWhitelist, "getDateOfBirth");

function Character:getSkin()
	local skinStr = MySQL.scalar.await("SELECT skin FROM characters WHERE id=?", {self.id});
	return json.decode(skinStr);
end
table.insert(Character.static.rpcWhitelist, "getSkin");

function Character:setSkin(skin)
	local skinStr = json.encode(skin);
	MySQL.update.await("UPDATE characters SET skin=? WHERE id=?", {skinStr, character.id});
end
table.insert(Character.static.rpcWhitelist, "setSkin");

function Character:getInventoryId()
	local inventoryId = MySQL.scalar.await("SELECT inventory_id FROM characters WHERE id=?", {self.id});
	return inventoryId;
end
table.insert(Character.static.rpcWhitelist, "getInventoryId");

function Character:getInventory()
	local inventoryId = self.getInventoryId();
	return inventoryClass.getById(inventoryId);
end

Character.static.Create = function(userId, firstname, lastname, dateofbirth, height, skin)
	local inventoryId = inventoryClass.Create(20);

	local skinStr = json.encode(skin);
	local id = MySQL.insert.await("INSERT INTO characters (user_id, firstname, lastname, dateofbirth, height, skin, position_x, position_y, position_z, inventory_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
		userId, 
		firstname, 
		lastname, 
		dateofbirth, 
		height, 
		skinStr, 
		213.78, 
		-900.12, 
		29.69,
		inventoryId,
	});

	return Character:new(id);
end;

Character.static.GetByPlayerId = function(playerId)
	local user = M("user").GetByPlayerId(playerId);
	
	if not user then
		logger.debug("User with player id " .. playerId .. " not found - returning nil");
		return nil;
	end

	return user.getCurrentCharacter();
end;

Character.static.GetAll = function()
	local characters = {};

	local data = MySQL.query.await("SELECT id FROM characters");
	for _,v in pairs(data) do
		table.insert(ret, module.getById(v.id));
	end

	return characters;
end;

callback.register("character:rpc", function(playerId, cb, id, name, ...)
	local character = module.getById(id);

	if not character then
		logger.warn("Character not found - rpc failed");
		return;
	end

	if character.getUser().getPlayerId() ~= playerId and not character.getUser().getIsAdmin() then
		logger.warn("Character not owned by requester - rpc failed");
		return;
	end	

	if not utils.table.contains(character.rpcWhitelist, name) then
		logger.warn("Requested character rpc " .. name .. " not whitelisted - rpc failed");
		return;
	end

	cb(character[name](...));
end);


module = Character;