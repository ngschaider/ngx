local callback = M("callback");
local Inventory = M("inventory");
local class = M("class");

local Character = class("Character");

function Character:initialize(id)
	self.id = id;
end

function Character:_rpc(name, ...)
	local p = promise.new();
	callback.trigger("character:rpc", function(...)
		p:resolve(...);
	end, self.id, name, ...);
	return Citizen.Await(p);
end

function Character:getName()
	return self:_rpc("getName");
end

function Character:getLastPosition()
	return self:_rpc("getLastPosition");
end;

function Character:getSkin()
	return self:_rpc("getSkin");
end;

function Character:setSkin(skin)
	self:_rpc("setSkin", skin);
end;

function Character:getInventoryId()
	return self:_rpc("getInventoryId");
end;

function Character:getInventory()
	local inventoryId = self:getInventoryId();
	return Inventory:new(inventoryId);
end;

local cache = {};
module.GetById = function(id)
	if not cache[id] then
		cache[id] = Character:new(id);
	end

	return cache[id];
end