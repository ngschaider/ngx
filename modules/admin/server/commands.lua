local command = M("command");
local logger = M("core").logger;
local event = M("core").event;

command.registerCommand("admin", function(user)
    logger.debug("command", "Command 'admin' executed!");
    user:emit("admin:OpenMenu");
end);

command.registerCommand("car", function(user, args)
    user:emit("admin:car", args[1]);
end);

command.registerCommand("freeze", function(user, args)
    local character = args[1];
    if character then
        character:getUser():emit("admin:freeze", args[1]);
    end
end)

command.registerCommand("tpm", function(user)
    user:emit("admin:tpm");
end)

command.registerCommand("coords", function(user)
    user:emit("admin:coords");
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
    local currentCharacter = user:getCurrentCharacter();
    if character and currentCharacter then
        local ped = GetPlayerPed(currentCharacter:getPlayerId());
        SetEntityCoords(ped, savedCoords[character.id]);

        savedCoords[character.id] = nil;
    end
end);

command.registerCommand("kill", function(user, args)
    local character = args[1];
    if character then
        character:getUser():emit("admin:kill");
    end
end, {
    args = {
        {type = "character"},
    }
});

command.registerCommand("freeze", function(user, args)
    local character = args[1];

    if character then
        character:getUser():emit("admin:freeze");
    end
end, {
    args = {
        {type = "character"},
    }
});

command.registerCommand("unfreeze", function(user, args)
    local character = args[1];
    if character then
        user:emit("admin:unfreeze", character.id);
    end
end, {
    args = {
        {type = "character"},
    }
});