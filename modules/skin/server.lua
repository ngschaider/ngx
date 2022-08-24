--[[
    
local event = M("event");
local command = M("command");
local callback = M("callback");

-command.registerCommand("getskin", function(user, args)
    callback.trigger("skin:getSkin", user.getPlayerId(), function(skin)
        print(json.encode(skin));
    end);
end, true, {
	help = "Gebe den aktuellen Charakter-Skin in der Konsole aus",
});

]]