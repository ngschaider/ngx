local callback = M("callback");
local characterClass = M("character");

local rpc = function(name, cb, ...)
	callback.trigger("user:rpc", cb, name, ...);
end;

module.getCharacterIds = function(cb)
	rpc("getCharacterIds", cb);
end;

module.getCharacters = function(cb)
    rpc("getCharacterIds", function(ids)
		local ret = {};
		for _,id in pairs(ids) do
			local character = characterClass.getById(id);
			table.insert(ret, character);
		end
		cb(ret);
	end);
end;

module.setCurrentCharacterId = function(id, cb)
	rpc("setCurrentCharacterId", cb, id);
end;

module.getCurrentCharacterId = function(cb)
	rpc("getCurrentCharacterId", cb);
end;

module.createCharacter = function(firstname, lastname, dateofbirth, height, skin, cb)
	rpc("createCharacter", function(id)
		local character = M("character").getById(id);
		cb(character);
	end, firstname, lastname, dateofbirth, height, skin);
end;