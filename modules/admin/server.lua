local command = M("command");
local logger = M("core").logger;
local event = M("core").event;

command.registerCommand("admin", function(user)
    logger.debug("command", "Command 'admin' executed!");
    event.emitClient("admin:OpenMenu", user:getPlayerId());
end, true);