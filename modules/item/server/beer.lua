local class = M("class");

local Beer = class("Beer", Item);

Beer.static.name = "beer";
Beer.static.label = "Bier";

function Beer:use()
    print("Beer got used!");
    self:destroy();
end

RegisterCommand("beer", function(playerId, args, rawCommand)
    logger.debug("giving player a beer");
    local beer = Beer:Create();
    logger.debug("beer");

    logger.debug("getting character");
    local character = M("character").GetByPlayerId(playerId);
    if not character then
        logger.debug("failed to get current character");
        return;
    end

    logger.debug("getting inventory")
    local inventory = character:getInventory();
    logger.debug("setting item inventoryId", inventory.id);
    beer:setInventoryId(inventory.id)
end, true);

RegisterItem(Beer);