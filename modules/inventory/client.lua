local callback = M("callback");
local itemClass = M("item");
local class = M("class");

local Inventory = class("Inventory");

function Inventory:initialize()
	self.id = id;
end

function Inventory:_rpc(name, ...)
	local p = promise.new();
	callback.trigger("inventory:rpc", function(...)
		p:resolve(...);
	end, self.id, name, ...);
	return Citizen.Await(p);
end

function Inventory:getMaxWeight()
	return self._rpc("getMaxWeight");
end;

function Inventory:getItemIds()
	return self._rpc("getItemIds");
end;

function Inventory:getItems()
	local ids = self.getItemIds();
	local items = {};
	for _,id in pairs(ids) do
		local item = itemClass.getById(itemId);
		table.insert(items, item);
	end

	return items;
end;

module = Inventory;