local commands = {};
module.registerCommand = function(name, cb, options)
	if not options then
		options = {};
	end

	local command = {
		name = name,
		cb = cb,
		options = options,
	};

	RegisterCommand(command.name, function(...)
		onCommandExecuted(command, ...);
	end, false);
end

local convertArgs = function(argument, config)
	if config.type == "user" then
		return User.GetById(argument);
	elseif config.type == "character" then
		return Character.GetById(argument);
	elseif config.type == "item" then
		return Item.GetbyId(argument);
	end
end

local onCommandExecuted = function(command, playerId, args, raw)
	local user = User.GetByPlayerId(playerId);

	if options.raw then
		cb(user, raw);
		return;
	end

	if options.args then
		local convertedArgs = {};
		for i=1,#options.args,1 do
			local convertedArg = convertArg(args[i], options.args[i]);
			table.insert(convertedArgs, convertedArg);
		end
		cb(user, args);
		return;
	end
end