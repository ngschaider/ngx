local utils = M("utils");
local characterClass = M("character");
local inventoryClass = M("inventory");
local itemClass = M("item");
local logger = M("logger");

RegisterCommand("ceval", function(source, args, rawCommand)
    local payload = utils.table.join(args, " ");
    print("evaling", payload);
    local fun = load(payload);
    fun();
end, true);