local callback = M("callback");
local Character = M("character");
local OOP = M("oop");

local User = OOP.CreateClass("User", function(self, id)
	local rpc = function(name, ...)
        local p = promise.new();
		callback.trigger("item:rpc", function(...) 
            p:resolve(...);
        end, self.id, name, ...);
        return Citizen.Await(p);
	end;

	self.id = id;

	self.getName = function()
		return rpc("getName");
	end;

	self.getCharacterIds = function()
		return rpc("getCharacterIds")
	end;
	
	self.getCharacters = function()
		local ids = self.getCharacterIds();
		local characters = {};
		for _,id in pairs(ids) do
			local character = Character.getById(id);
			table.insert(characters, character);
		end
		return characters;
	end;
	
	self.setCurrentCharacterId = function(id)
		rpc("setCurrentCharacterId", id);
	end;
	
	self.getCurrentCharacterId = function()
		return rpc("getCurrentCharacterId");
	end;
	
	self.getCurrentCharacter = function()
		local currentCharacterId = self.getCurrentCharacterId();
		if currentCharacterId then
			return Character.getById(currentCharacterId);
		else
			return nil;
		end
	end;
	
	self.createCharacter = function(firstname, lastname, dateofbirth, height, skin)
		local id = rpc("createCharacter", firstname, lastname, dateofbirth, height, skin);
		return Character.GetById(id);
	end;
end);
module.GetById = User.constructor;

User.GetSelf = function()
	local p = promise.new();
	callback.trigger("user:getSelfId", function(id)
		p:resolve(id);
	end);
	local id = Citizen.Await(p);
	return User.GetById(id);
end;
module.GetSelf = User.GetSelf;

User.GetAllOnline = function(cb)
	local p = promise.new();
	callback.trigger("user:getAllOnlineIds", function(ids)
		p:resolve(ids);
	end);
	local ids = Citizen.Await(p);

	local users = {};
	for _,id in pairs(ids) do
		local user = User.GetById(id);
		table.insert(users, user);
	end

	return users;
end;
module.GetAllOnline = User.GetAllOnline;