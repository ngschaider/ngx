local command = M("command");
local utils = M("utils");

command.registerCommand("eval", function(args)
    print("evaling", utils.table.join(args, " "));
end, true, {
    rawArgs = true
});