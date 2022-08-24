local callback = M("callback");
local utils = M("utils");
local logger = M("logger");
local event = M("event");
local skin = M("skin");
local inventoryClass = M("inventory");
local class = M("class");

local Construct = class.CreateClass({
	name = "Character",
}, function(self, id)
	local rpc = function(name, cb, ...)
		callback.trigger("character:rpc", cb, self.id, name, ...);
	end;

	self.id = id;

	self.getName = function()
		local p = promise.new();
		rpc("getName", function(name)
			p:resolve(name);
		end);
		return Citizen.Await(p);
	end;

	self.getLastPosition = function()
		local p = promise.new()
		rpc("getLastPosition", function(lastPosition)
			p:resolve(lastPosition)
		end);
		return Citizen.Await(p);
	end;

	self.getSkin = function()
		local p = promise.new();
		rpc("getSkin", function(skin)
			p:resolve(skin);
		end);
		return Citizen.Await(p);
	end;
	
	self.setSkin = function(skin)
		local p = promise.new();
		rpc("setSkin", function()
			p:resolve();
		end, skin);
		return Citizen.Await(p);
	end;

	self.getInventoryId = function()
		local p = promise.new();
		rpc("getInventoryId", function(inventoryId)
			p:resolve(inventoryId);
		end);
		return Citizen.Await(p);
	end;

	self.getInventory = function()
		local inventoryId = self.getInventoryId();
		return inventoryClass.getById(inventoryId);
	end;
end);

module.getById = function(id)
	return Construct(id);
end;