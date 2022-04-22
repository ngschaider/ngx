local logger = M("logger");
local utils = M("utils");
local callback = M("callback");
local event = M("event");
local game = M("game");

local users = {};

local Construct = function(id)
	local self = {};

	self.id = id;

	self.identifier = MySQL.scalar.await("SELECT identifier FROM users WHERE id=?", {self.id});
	if not self.identifier then
		return nil;
	end

	self.rpcWhitelist = {};

	self.emit = function(name, ...)
		event.emitClient(name, self.getPlayerId(), ...);
	end;

	self.getPlayerId = function()
		for k,v in pairs(GetPlayers()) do
			if utils.getIdentifier(v) == self.identifier then
				return tonumber(v);
			end
		end
		
		return nil;
	end;

	self.getIsOnline = function()
		return self.getPlayerId() ~= nil;
	end;

	self.kick = function(reason)
		if not self.getIsOnline() then return end
		DropPlayer(self.playerId, reason);
	end;

	self.getIdentifier = function()
		return self.identifier;
	end;

	self.showNotification = function(msg)
		self.emit("notification:showNotification", msg);
	end;

	self.showHelpNotification = function(msg, thisFrame, beep, duration)
		self.emit("notification:showHelpNotification", msg, thisFrame, beep, duration);
	end;

	event.emit("user:construct:after", self);

	return self;
end;

local Create = function(identifier)
    local id = MySQL.insert.await("INSERT INTO users (identifier) VALUES (?)", {identifier});
	local user = module.getById(id);

	event.emit("user:create:after", user);

	return user;
end

module.getById = function(id)
	if not users[id] then
		users[id] = Construct(id);
	end

	return users[id];
end;

module.getByIdentifier = function(identifier)
	local id = MySQL.scalar.await("SELECT id FROM users WHERE identifier=?", {identifier});
	
	if id then
		return module.getById(id);
	else
		local user = Create(identifier);
		users[user.id] = user;
		return user;
	end
end;

module.getByPlayerId = function(playerId)
	local identifier = utils.getIdentifier(playerId);
	return module.getByIdentifier(identifier);
end;

callback.register("user:rpc", function(playerId, cb, name, ...)
	local user = module.getByPlayerId(playerId);
	
	if not utils.table.contains(user.rpcWhitelist, name) then
		logger.warn("function name " .. name .. " not in whitelist - user rpc failed.");
		return;
	end

	cb(user[name](...));
end);
