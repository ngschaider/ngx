local utils = M("utils");
local logger = M("core").logger;

RegisterCommand("eval", function(source, args, rawCommand)
    local payload = utils.table.join(args, " ");
    logger.debug("eval", "evaling", payload);
    local func = load(payload);
    func();
end, true);