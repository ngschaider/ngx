local command = M("command");
local utils = M("utils");
local Character = M("character");
local Inventory = M("inventory");
local Item = M("item");
local logger = M("logger");

RegisterCommand("eval", function(source, args, rawCommand)
    local payload = utils.table.join(args, " ");
    logger.debug("evaling", payload);
    local func = load(payload);
    func();
end, true);