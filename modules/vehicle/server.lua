run("server/class.lua");

local command = M("command");
local core = M("core");
local logger = M("core").logger;
local net = M("core").net;

command.register("givevehicletocharacter", function(user, args)
    local character = args[1];
    logger.debug("vehicle", "givevehicletocharacter", "character.type, character.id", character.type, character.id);
    module.Create(args[2], character);
    logger.info("vehicle", "givevehicletocharacter", "Added vehicle " .. args[2] .. " to character " .. character.id);
end, {
    args = {
        {type = "character"}
    }
});


command.register("setdata", function(user, args)
    local type = args[1];
    local id = args[2];
    local key = args[3];
    local value = args[4];

    local obj = core.GetSyncObject(type, id);
    obj:setData(key, value);
end)

command.register("getdata", function(user, args)
    local type = args[1];
    local id = args[2];
    local key = args[3];

    local obj = core.GetSyncObject(type, id);
    local value = obj:getData(key);
    net.send(user, "core:print", type .. "(" .. id .. ")[" .. key .. "]: " .. json.encode(value));
end)