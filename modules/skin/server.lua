--[[
    
local net = M("core").net;
local command = M("command");
local callback = M("core").callback;

command.registerCommand("getskin", function(user, args)
    callback.trigger(user, "skin:getSkin", function(skin)
        --print(json.encode(skin));
    end);
end, true, {
	help = "Gebe den aktuellen Charakter-Skin in der Konsole aus",
});

]]