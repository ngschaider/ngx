local command = M("command");
local logger = M("core").logger;
local net = M("core").net;

command.registerCommand("admin", function(user)
    logger.debug("command", "Command 'admin' executed!");
    net.send(user, "admin:OpenMenu");
end);

command.registerCommand("car", function(user, args)
    net.send(user, "admin:car", args[1]);
end);

command.registerCommand("freeze", function(user, args)
    local character = args[1];
    if character then
        net.send(character:getUser(), "admin:freeze", args[1]);
    end
end)

command.registerCommand("tpm", function(user)
    net.send(user, "admin:tpm");
end)

command.registerCommand("coords", function(user)
    net.send(user, "admin:coords");
end)


local savedCoords = {};
command.registerCommand("bring", function(user, args)
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

command.registerCommand("bringback", function(user, args)
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

command.registerCommand("goto", function(user, args)
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

command.registerCommand("goback", function(user)
    local character = user:getCurrentCharacter();
    if character then
        local ped = GetPlayerPed(character:getPlayerId());
        SetEntityCoords(ped, savedCoords[character.id]);

        savedCoords[character.id] = nil;
    end
end);

command.registerCommand("kill", function(user, args)
    local character = args[1];
    if character then
        net.send(character:getUser(), "admin:kill");
    end
end, {
    args = {
        {type = "character"},
    }
});

command.registerCommand("freeze", function(user, args)
    local character = args[1];

    if character then
        net.send(character:getUser(), "admin:freeze");
    end
end, {
    args = {
        {type = "character"},
    }
});

command.registerCommand("unfreeze", function(user, args)
    local character = args[1];
    if character then
        net.send(character:getUser(), "admin:unfreeze");
    end
end, {
    args = {
        {type = "character"},
    }
});