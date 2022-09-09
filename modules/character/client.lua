local Inventory = M("inventory");
local class = M("class");
local logger = M("core").logger;
local core = M("core");
local Event = M("event");

local Character = class("Character", core.SyncObject);
core.RegisterSyncClass(Character);

function Character:initialize(id)
	core.SyncObject.initialize(self, "Character", id, "characters");
end

function Character:getId()
	return self:getData("id");
end

function Character:getUserId()
	return self:getData("userId");
end

function Character:getLastPosition()
	return vector3(
		tonumber(self:getData("lastPositionX")),
		tonumber(self:getData("lastPositionY")),
		tonumber(self:getData("lastPositionZ"))
	);
end

function Character:getName()
	return self:getData("firstname") .. " " .. self:getData("lastname");
end

function Character:getSkin()
	return json.decode(self:getData("skin"));
end

function Character:setSkin(skin)
	self:rpc("setSkin", skin);
end

function Character:getInventoryId()
	return self:getData("inventoryId");
end

function Character:getInventory()
	logger.debug("character", "Character:getInventory");
	local id = self:getInventoryId();
	logger.debug("character", "Character:getInventory", "id", id);
	return Inventory.GetById(id);
end

module.GetById = function(id)
	return core.GetSyncObject("Character", id);
end

module.onCharacterSpawned = Event:new();