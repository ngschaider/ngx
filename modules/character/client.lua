local callback = M("callback");
local Inventory = M("inventory");
local class = M("class");

local Character = class("Character");

function Character:initialize(id)
	print("Character.initialize", "id", id);
	self.id = id;
end

function Character:_rpc(name, ...)
	print("Character.rpc", name, self.id);
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
	local id = self:getInventoryId();
	return Inventory.GetById(id);
end;

module.GetById = function(id)
	return Character:new(id);
end