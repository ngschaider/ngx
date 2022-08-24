local callback = M("callback");
local characterClass = M("character");
local class = M("class");

local users = {};

local rpc = function(name, cb, ...)
	callback.trigger("user:rpc", cb, name, ...);
end;

local Construct = class.CreateClass({
	name = "User",
}, function(self, id)
	self.id = id;

	self.getName = function()
		local p = promise.new();
		rpc("getName", function(name)
			p:resolve(name)
		end);
		return Citizen.Await(p);
	end;

	self.getCharacterIds = function()
		local p = promise.new();
		rpc("getCharacterIds", function(characterIds)
			p:resolve(characterIds);
		end);
		return Citizen.Await(p);
	end;
	
	self.getCharacters = function()
		local p = promise.new();
		rpc("getCharacterIds", function(ids)
			local characters = {};
			for _,id in pairs(ids) do
				local character = characterClass.getById(id);
				table.insert(characters, character);
			end
			p:resolve(characters);
		end);
		return Citizen.Await(p);
	end;
	
	self.setCurrentCharacterId = function(id)
		local p = promise.new();
		--print("setCurrentCharacterId", id);
		rpc("setCurrentCharacterId", function()
			p:resolve();
		end, id);
		return Citizen.Await(p);
	end;
	
	self.getCurrentCharacterId = function()
		local p = promise.new();
		rpc("getCurrentCharacterId", function(currentCharacterId)
			p:resolve(currentCharacterId);
		end);
		return Citizen.Await(p);
	end;
	
	self.getCurrentCharacter = function()
		local currentCharacterId = self.getCurrentCharacterId();
		if currentCharacterId then
			return characterClass.getById(currentCharacterId);
		else
			return nil;
		end
	end;
	
	self.createCharacter = function(firstname, lastname, dateofbirth, height, skin)
		local p = promise.new();
		rpc("createCharacter", function(id)
			local character = characterClass.getById(id);
			p:resolve(character);
		end, firstname, lastname, dateofbirth, height, skin);
		return Citizen.Await(p);
	end;
end);

module.getById = function(id)
	return Construct(id);
end;

module.getSelf = function()
	local p = promise.new();
	callback.trigger("user:getSelfId", function(selfUserId)
		local selfUser = Construct(selfUserId);
		p:resolve(selfUser);
	end);
	return Citizen.Await(p);
end;

module.getAllOnline = function(cb)
	local p = promise.new();
	callback.trigger("user:getAllOnlineIds", function(ids)
		local onlineUsers = {};
		for _,id in pairs(ids) do
			table.insert(onlineUsers, module.getById(id));
		end
		p:resolve(onlineUsers);
	end);
	return Citizen.Await(p);
end;