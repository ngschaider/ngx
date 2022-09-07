local utils = M("utils");
local callback = M("core").callback;
local logger = M("core").logger;
local Inventory = M("inventory");
local class = M("class");
local core = M("core");

local Character = class("Character", core.SyncObject);
core.RegisterSyncClass(Character);

function Character:initialize(id)
	logger.debug("character", "Character:initialize", "id", id);
	core.SyncObject.initialize(self, "Character", id, "characters");

	self:syncProperty("id", true, false);
	self:syncProperty("userId", true, false);
	self:syncProperty("lastPositionX", true, false);
	self:syncProperty("lastPositionY", true, false);
	self:syncProperty("lastPositionZ", true, false);
	self:syncProperty("firstname", true, false);
	self:syncProperty("lastname", true, false);
	self:syncProperty("dateOfBirth", true, false);
	self:syncProperty("inventoryId", true, false);
	self:rpcMethod("getSkin", true);
	self:rpcMethod("setSkin", true);
end

function Character:getId()
	return self:getData("id");
end

function Character:getUserId()
	return self:getData("userId");
end

function Character:getUser()
	local userId = self:getUserId();
	return M("user").GetById(userId);
end

function Character:getPosition()
	local playerId = self:getUser():getPlayerId();
	local ped = GetPlayerPed(playerId);
	return GetEntityCoords(ped);
end

function Character:getLastPosition()
	return vector3(
		self:getData("lastPositionX"),
		self:getData("lastPositionY"),
		self:getData("lastPositionZ")
	);
end

function Character:getName()
	return self:getData("firstname") .. " " .. self:getData("lastname");
end

function Character:getDateOfBirth()
	return self:getData("dateOfBirth");
end

function Character:getSkin()
	logger.debug("character", "Character:getSkin", "self:getName()", self:getName());
	logger.debug("character", "Character:getSkin", "self._data", json.encode(self._data));
	return json.decode(self:getData("skin"));
end

function Character:setSkin(skin)
	local skinStr = json.encode(skin);
	MySQL.update.await("UPDATE characters SET skin=? WHERE id=?", {skinStr, self.id});
	self:setData("skin", skinStr);
end

function Character:getInventoryId()
	logger.debug("character", "Character:getInventoryId", "self.id", self.id);
	local inventoryId = self:getData("inventoryId");
	logger.debug("character", "Character:getInventoryId", "inventoryId", inventoryId);
	return inventoryId;
end

function Character:getInventory()
	logger.debug("character", "Character:getInventory");
	local inventoryId = self:getInventoryId();
	logger.debug("character", "Character:getInventory", "inventoryId", inventoryId);
	return Inventory.GetById(inventoryId);
end

module.GetById = function(id)
	return core.GetSyncObject("Character", id);
end

module.Create = function(userId, firstname, lastname, dateOfBirth, skin)
	local inventoryId = Inventory.Create(20);

	local skinStr = json.encode(skin);
	local id = MySQL.insert.await("INSERT INTO characters (userId, firstname, lastname, dateOfBirth, skin, lastPositionX, lastPositionY, lastPositionZ, inventoryId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {
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
		logger.error("character", "User with player id " .. playerId .. " not found - returning nil");
		return nil;
	end

	logger.debug("character", "Character.static:GetByPlayerId", "user.id", user.id)
	return user:getCurrentCharacter();
end

module.GetAll = function()
	local results = MySQL.query.await("SELECT id FROM characters");

	local characters = utils.table.mapValues(results, function(v)
		return module.GetById(v.id);
	end)
	return characters;
end