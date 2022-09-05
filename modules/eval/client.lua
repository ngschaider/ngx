local utils = M("utils");
local Character = M("character");
local Inventory = M("inventory");
local Item = M("item");
local logger = M("core").logger;

RegisterCommand("ceval", function(source, args, rawCommand)
    local payload = utils.table.join(args, " ");
    logger.debug("eval", "evaling", payload);
    local fun = load(payload);
    fun();
end, true);