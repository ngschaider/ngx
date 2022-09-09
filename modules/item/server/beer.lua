local logger = M("core").logger;
local Character = M("character");

module.Register({
    name = "beer",
    label = "Bier",
    isUsable = true,
    isDroppable = true,
    onUse = function(item)
        print("Beer got used!");
        item:destroy();
    end,
});

RegisterCommand("beer", function(playerId, args, rawCommand)
    logger.debug("item->beer", "giving player a beer");
    local beer = module.Create("beer");
    logger.debug("item->beer", "beer");

    logger.debug("item->beer", "getting character");
    local character = Character.GetByPlayerId(playerId);
    if not character then
        logger.debug("item->beer", "failed to get current character");
        return;
    end

    logger.debug("item->beer", "getting inventory")
    local inventory = character:getInventory();
    logger.debug("item->beer", "setting item inventoryId", inventory.id);
    beer:setInventory(inventory);
end, true);