local command = M("command");
local logger = M("logger");
local event = M("core").event;

command.registerCommand("admin", function(user)
    logger.debug("User " .. user.id .. " opened the Admin Menu");
    event.emitClient("admin:OpenMenu", user:getPlayerId());
end, true);