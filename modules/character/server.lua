local utils = M("utils");
local callback = M("callback");
local event = M("event");
local logger = M("logger");
local inventoryClass = M("inventory");
local OOP = M("oop");

local Character = OOP.CreateClass("Character", function(self, id)
	self.id = id;
	self.rpcWhitelist = {};

	self.getId = function()
		return self.id;
	end;
	table.insert(self.rpcWhitelist, "getId");

	self.getUserId = function()
		local userId = MySQL.scalar.await("SELECT user_id FROM characters WHERE id=?", {self.id});
		return tonumber(userId);
	end;
	table.insert(self.rpcWhitelist, "getUserId");

	self.getUser = function()
		local userId = self.getUserId();
		return M("user").getById(userId);
	end;

	self.setPosition = function(coords)
		utils.teleport(coords);
	end;

	self.getPosition = function()
		local playerId = self.getUser().getPlayerId();
		local ped = GetPlayerPed(playerId);
		return GetEntityCoords(ped);
	end;

	self.getLastPosition = function()
		local results = MySQL.single.await("SELECT position_x, position_y, position_z FROM characters WHERE id=?", {self.id});
		return {
			x = tonumber(results.position_x),
			y = tonumber(results.position_y),
			z = tonumber(results.position_z),
		};
	end;
	table.insert(self.rpcWhitelist, "getLastPosition");
	
	self.getName = function()
		local result = MySQL.single.await("SELECT firstname, lastname FROM characters WHERE id=?", {self.id});
		return result.firstname .. " " .. result.lastname;
	end;
	table.insert(self.rpcWhitelist, "getName");

	self.getHeight = function()
		local height = MySQL.scalar.await("SELECT height FROM characters WHERE id=?", {self.id});
		return height;
	end;
	table.insert(self.rpcWhitelist, "getHeight");

	self.getDateOfBirth = function()
		local dateOfBirth = MySQL.scalar.await("SELECT dateofbirth FROM characters WHERE id=?", {self.id});
		return dateOfBirth;
	end;
	table.insert(self.rpcWhitelist, "getDateOfBirth");

	self.getSkin = function()
        local skinStr = MySQL.scalar.await("SELECT skin FROM characters WHERE id=?", {self.id});
        return json.decode(skinStr);
    end;
    table.insert(self.rpcWhitelist, "getSkin");

    self.setSkin = function(skin)
        local skinStr = json.encode(skin);
        MySQL.update.await("UPDATE characters SET skin=? WHERE id=?", {skinStr, character.id});
    end;
    table.insert(self.rpcWhitelist, "setSkin");

	self.getInventoryId = function()
		local inventoryId = MySQL.scalar.await("SELECT inventory_id FROM characters WHERE id=?", {self.id});
		return inventoryId;
	end;
	table.insert(self.rpcWhitelist, "getInventoryId");

	self.getInventory = function()
		local inventoryId = self.getInventoryId();
		return inventoryClass.getById(inventoryId);
	end;
end);
module.GetById = Character.constructor;

Character.Create = function(userId, firstname, lastname, dateofbirth, height, skin)
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

	return id;
end;
module.Create = Character.Create;

Character.GetByPlayerId = function(playerId)
	local user = M("user").GetByPlayerId(playerId);
	
	if not user then
		logger.debug("User with player id " .. playerId .. " not found - returning nil");
		return nil;
	end

	return user.getCurrentCharacter();
end;
module.GetByPlayerId = Character.GetByPlayerId;

Character.GetAll = function()
	local ret = {};

	local data = MySQL.query.await("SELECT id FROM characters");
	for _,v in pairs(data) do
		table.insert(ret, module.getById(v.id));
	end

	return ret;
end;
module.GetAll = Character.GetAll;

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

