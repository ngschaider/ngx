local userClass = M("user");
local characterClass = M("character");
local logger = M("logger");
local job = M("job");
local event = M("event");

local registeredCommands = {};
local validators = {};
local valueConverters = {};

local convert = function(value, type, args)
	if converters[type] then
		return validators[type](value, table.unpack(args));
	else
		return value;
	end
end;

local validate = function(value, type, args)
	if validators[type] then
		return validators[type](value, table.unpack(args));
	else
		return true;
	end
end;

local addSuggestion = function(commandName, info)
	local suggestionArgs = {};

	for k,v in pairs(info.arguments) do
		table.insert(suggestionArgs, {
			name = info.name or "",
			help = info.help or "",
		})
	end

	TriggerClientEvent("chat:addSuggestion", -1, "/" .. commandName, info.help, suggestionArgs);
end;

module.registerCommand = function(commandName, cb, restricted, info)
	info = info or {};
	info.arguments = info.arguments or {};
	info.help = info.help or {};

	RegisterCommand(commandName, function(playerId, args, rawCommand)
		local newArgs = {};

		for k,v in pairs(info.arguments) do
			newArgs[v.name] = args[k];

			if v.type then
				local valid = validate(newArgs[v.name], v.type, v.args);
				if not valid then
					logger.info("Invalid command argument " .. newArgs[v.name]);
					return;
				end

				newArgs[v.name] = convert(newArgs[v.name], v.type, v.args);
			end
		end

		local user = userClass.getByPlayerId(playerId);

		cb(user, newArgs);
	end, restricted);

	logger.info("Registered command '" .. commandName .. "'");

	addSuggestion(commandName, info);
	table.insert(registeredCommands, {
		name = commandName,
		info = info,
	});
end;

event.onClient("base:playerJoined", function()
	for k,v in pairs(registeredCommands) do
		addSuggestion(v.name, v.info);
	end
end);