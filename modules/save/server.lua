local Character = M("character");
local logger = M("core").logger;
local net = M("core").net;

local SaveCharacter = function(character)
    logger.debug("save", "Saving Character", character.id);
    logger.debug("save", "character.id", character.id);
    local user = character:getUser();
    logger.debug("save", "user.id", user.id);
    logger.debug("save", "user:getPlayerId()", user:getPlayerId());
    logger.debug("save", "user:getIsOnline()", user:getIsOnline());
    logger.debug("save", "user:getCurrentCharacterId()", user:getCurrentCharacterId());
    logger.debug("save", "character:getId()", character:getId());
    if user:getIsOnline() and user:getCurrentCharacterId() == character:getId() then
        local position = character:getPosition();
        logger.debug("save", "Saving position of character", character:getName(), position.x, position.y, position.z);
        MySQL.update("UPDATE characters SET lastPositionX=?, lastPositionY=?, lastPositionZ=? WHERE id=?", {
            position.x,
            position.y,
            position.z,
            character.id,
        });
    end
end;

local SaveCharacters = function()
    local characters = Character.GetAll();
    for _, character in pairs(characters) do
        SaveCharacter(character);
    end
end;

-- save when player dropped
net.on("net:playerDropped", function(playerId, reason)
    local character = Character.GetByPlayerId(playerId);
    if character then
        logger.debug("save", "Saving " .. character:getName() .. " because they left.");
        SaveCharacter(character);
    end
end);

--[[
-- Disabled because there is not enough time to execute MySQL queries. 
-- Maybe this can be fixed by using synchronous queries.

net.on("net:resourceStop", function()
    logger.info("save", "Saving characters because the resource shuts down.");
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

        logger.info("save", "Timer ran out. Saving characters...");
        SaveCharacters();
    end
end)