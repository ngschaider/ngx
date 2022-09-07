local class = M("class");

module.RegisterItem({
    name = "beer",
    label = "Bier",
    onUse = function(item)
        print("Beer got used!");
        self:destroy();
    end,
})



RegisterCommand("beer", function(playerId, args, rawCommand)
    logger.debug("item->beer", "giving player a beer");
    local beer = Beer:Create();
    logger.debug("item->beer", "beer");

    logger.debug("item->beer", "getting character");
    local character = M("character").GetByPlayerId(playerId);
    if not character then
        logger.debug("item->beer", "failed to get current character");
        return;
    end

    logger.debug("item->beer", "getting inventory")
    local inventory = character:getInventory();
    logger.debug("item->beer", "setting item inventoryId", inventory.id);
    beer:setInventoryId(inventory.id)
end, true);