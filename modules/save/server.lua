local characterClass = M("character");
local logger = M("logger");
local event = M("event");

local SaveCharacter = function(character)
    logger.debug("Saving Character", character.id);
    --logger.debug("save", "character.id", character.id);
    local user = character.getUser();
    --logger.debug("save", "user.id", user.id);
    --logger.debug("save", "user.getIsOnline()", user.getIsOnline());
    --logger.debug("save", "user.getCurrentCharacterId()", user.getCurrentCharacterId());
    if user.getIsOnline() and user.getCurrentCharacterId() == character.id then
        local position = character.getPosition();
        print("Saving position of character", character.getName(), position.x, position.y, position.z);
        MySQL.update("UPDATE characters SET position_x=?, position_y=?, position_z=? WHERE id=?", {
            position.x, 
            position.y,
            position.z, 
            character.id
        });
    end
end;

local SaveCharacters = function()
    for _, character in pairs(characterClass.getAll()) do
        SaveCharacter(character);
    end
end;

-- save when player dropped
event.on("event:playerDropped", function(playerId, reason)
    local character = characterClass.getByPlayerId(playerId);
    if character then
        print("Saving " .. character.getName() .. " because they left.");
        SaveCharacter(character);
    end
end);

--[[
event.on("event:resourceStop", function()
    print("Saving characters because the resource shuts down.");
    SaveCharacters();
end);
]]

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 then
        Citizen.CreateThread(function()
            Citizen.Wait(50 * 1000);
            SaveCharacters();
        end);
    end
end);

-- save every minute
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60 * 1000) -- 1 minute = 60 seconds = 60 * 1000 milliseconds

        print("Timer ran out. Saving characters...");
        SaveCharacters();
    end
end)