local callback = M("callback");

local Construct = class.CreateClass({
    name = "Item",
}, function(self, id)
	local rpc = function(name, ...)
        local p = promise.new();
		callback.trigger("item:rpc", function(...) 
            --print("resolving", ...);
            p:resolve(...);
        end, self.id, name, ...);
        return Citizen.Await(p);
	end;

	self.id = id;

	self.getName = function()
		return rpc("getName");
	end;

    self.getType = function()
        return rpc("getType");
    end;

    self.getInventoryId = function()
        return rpc("getInventoryId");
    end;

    self.getInventory = function()
        local inventoryId = self.getInventoryId();
        return M("inventory").getById(inventoryId);
    end;

    self.setInventoryId = function(inventoryId)
        return rpc("setInventoryId", inventoryId);
    end;

    self.setInventory = function(inventory)
        self.setInventoryId(inventory.id);
    end;

    self.getConfig = function()
        print("getting type");
        local type = self.getType();
        print("type=" .. type);
        print(json.encode(ItemConfigs));
        utils.table.find(ItemConfigs, function(itemConfig) 
            print("comparing", itemConfig.type, type);
            return itemConfig.type == type;
        end);
    end;

    self.use = function()
        rpc("use");
    end
end);

module.getById = function(id)
	return Construct(id);
end;