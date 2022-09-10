local command = M("command");
local logger = M("core").logger;
local net = M("core").net;

command.register("admin", function(user)
    logger.debug("command", "Command 'admin' executed!");
    net.send(user, "admin:OpenMenu");
end);

command.register("car", function(user, args)
    net.send(user, "admin:car", args[1]);
end);

command.register("freeze", function(user, args)
    local character = args[1];
    if character then
        net.send(character:getUser(), "admin:freeze", args[1]);
    end
end)

command.register("tpm", function(user)
    net.send(user, "admin:tpm");
end)

command.register("coords", function(user)
    net.send(user, "admin:coords");
end)


local savedCoords = {};
command.register("bring", function(user, args)
    local currentCharacter = user:getCurrentCharacter();
    local character = args[1];
    if character and character:getUser():getIsOnline() and currentCharacter then
        savedCoords[character.id] = character:getPosition();
        character:setPosition(currentCharacter:getPosition());

        local ped = GetPlayerPed(character:getUser():getPlayerId());
        SetEntityCoords(ped, character:getPosition());
    end
end, {
    args = {
        {type = "character"}
    }
});

command.register("bringback", function(user, args)
    local character = args[1];
    if character and character:getUser():getIsOnline() and savedCoords[character.id] then
        local ped = GetPlayerPed(character:getUser():getPlayerId());
        SetEntityCoords(ped, savedCoords[character.id]);
        savedCoords[character.id] = nil;
    end
end, {
    args = {
        {type = "character"}
    }
});

command.register("goto", function(user, args)
    local currentCharacter = user:getCurrentCharacter();
    local character = args[1];
    if character and currentCharacter then
        local pos = character:getPosition();
        savedCoords[character.id] = pos;

        local ped = GetPlayerPed(currentCharacter:getPlayerId());
        SetEntityCoords(ped, pos);
    end
end, {
    args = {
        {type = "character"},
    }
})

command.register("goback", function(user)
    local character = user:getCurrentCharacter();
    if character then
        local ped = GetPlayerPed(character:getPlayerId());
        SetEntityCoords(ped, savedCoords[character.id]);

        savedCoords[character.id] = nil;
    end
end);

command.register("kill", function(user, args)
    local character = args[1];
    if character then
        net.send(character:getUser(), "admin:kill");
    end
end, {
    args = {
        {type = "character"},
    }
});

command.register("freeze", function(user, args)
    local character = args[1];

    if character then
        net.send(character:getUser(), "admin:freeze");
    end
end, {
    args = {
        {type = "character"},
    }
});

command.register("unfreeze", function(user, args)
    local character = args[1];
    if character then
        net.send(character:getUser(), "admin:unfreeze");
    end
end, {
    args = {
        {type = "character"},
    }
});


command.register("getcharacterid", function(user, args)
    local character = user:getCurrentCharacter();
    if character then
        net.send(user, "core:print", "Charakter-ID: " .. character.id);
    end
end);

command.register("getuserid", function(user, args)
    net.send(user, "core:print", "User-ID: " .. user.id);
end);