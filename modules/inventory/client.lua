local callback = M("callback");
local itemClass = M("item");
local class = M("class");

local Construct = class.CreateClass({
	name = "Inventory",
}, function(self, id)
	local rpc = function(name, ...)
		local p = promise.new();
		callback.trigger("inventory:rpc", function(...)
			p:resolve(...);
		end, self.id, name, ...);
		return Citizen.Await(p);
	end;

	self.id = id;

	self.getMaxWeight = function()
		return rpc("getMaxWeight");
	end;

    self.getItemIds = function()
		return rpc("getItemIds");
	end;

    self.getItems = function()
        local itemIds = self.getItemIds();
		print("got item Ids");

        local items = {};
        for _,itemId in pairs(itemIds) do
			print("getting item", itemId);
            local item = itemClass.getById(itemId);
            table.insert(items, item);
        end

        return items;
    end;
end);

module.getById = function(id)
	return Construct(id);
end;