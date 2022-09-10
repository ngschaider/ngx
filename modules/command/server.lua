local logger = M("core").logger;
local User = M("user");
local Character = M("character");

local convertArg = function(argument, config)
	if config.type == "user" then
		return User.GetById(argument);
	elseif config.type == "character" then
		return Character.GetById(argument);
	elseif config.type == "item" then
		return Item.GetById(argument);
	end
end

local onCommandExecuted = function(command, playerId, args, raw)
	local user = User.GetByPlayerId(playerId);

	if command.options.raw then
		command.cb(user, raw);
		return;
	end

	if command.options.args then
		local convertedArgs = {};
		for i=1,#args,1 do
			if command.options.args[i] then
				local convertedArg = convertArg(args[i], command.options.args[i]);
				logger.debug("command", "Converting " .. args[i] .. " into type " .. command.options.args[i].type);
				table.insert(convertedArgs, convertedArg);
			else
				table.insert(convertedArgs, args[i]);
			end
		end
		command.cb(user, convertedArgs);
		return;
	end
end

module.register = function(name, cb, options)
	logger.info("command", "Command '" .. name .. "' registered.");
	
	options = options or {};
	options.args = options.args or {};

	local command = {
		name = name,
		cb = cb,
		options = options,
	};

	RegisterCommand(command.name, function(playerId, args, raw)
		Citizen.CreateThread(function()
			onCommandExecuted(command, playerId, args, raw);
		end);
	end, false);
end