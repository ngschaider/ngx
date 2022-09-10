--[[
    
local net = M("core").net;
local command = M("command");
local callback = M("core").callback;

command.register("getskin", function(user, args)
    local skin = callback.trigger(user, "skin:getSkin");
    print(json.encode(skin));
end, true, {
	help = "Gebe den aktuellen Charakter-Skin in der Konsole aus",
});

]]