local callback = M("callback");
local Item = M("item");
local class = M("class");
local logger = M("logger");
local utils = M("utils");

local Inventory = class("Inventory");

function Inventory:initialize(id)
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
	return self:_rpc("getMaxWeight");
end

function Inventory:getItemIds()
	return self:_rpc("getItemIds");
end

function Inventory:getItems()
	logger.debug("Inventory.getItems", "getting item ids");
	local ids = self:getItemIds();
	logger.debug("Inventory.getItems", "ids", json.encode(ids));
	
	local items = utils.table.map(ids, function(id)
		logger.debug("Inventory.getItems", "id", id);
		return Item.GetById(id);
	end);

	return items;
end

module.GetById = function(id)
	return Inventory:new(id);
end;