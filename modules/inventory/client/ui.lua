local User = M("user");
local UI = M("UI");
local logger = M("core").logger;

RegisterCommand("inventory", function()
    OpenOwnCharacterInventory();
end);
RegisterKeyMapping("inventory", "Inventar öffnen", "keyboard", "F2");

function OpenOwnCharacterInventory()
    local user = User:GetSelf();
    logger.debug("inventory_ui", "OpenOwnCharacterInventory", "user", user);
    local character = user:getCurrentCharacter();
    logger.debug("inventory->ui", "OpenOwnCharacterInventory", "character", character);
    if not character then
        logger.debug("inventory->ui", "returning");
        return
    end
    logger.debug("inventory->ui", "getting inv");
    local inventory = character:getInventory();
    logger.debug("inventory->ui", "OpenOwnCharacterInventory", "inventory", inventory);
    OpenInventory(inventory);
end;

function OpenInventory(inventory)
    logger.debug("inventory->ui", "creating menu");
    local menu = UI.CreateMenu("Inventar", "");

    logger.debug("inventory_ui", "OpenInventory", "inventory.id", inventory.id);
    local items = inventory:getItems();
    logger.debug("inventory->ui", "OpenInventory", "#items", #items);

    local itemsStacked = {};
    for _,item in pairs(items) do
        local index = utils.table.findIndex(itemsStacked, function(v)
            return v:getItemData() == item:getItemData();
        end);

        if index then
            itemsStacked[index] = itemsStacked[index] + 1;
        else
            itemsStacked[item] = 1;
        end
    end

    for item,amount in pairs(itemsStacked) do
        logger.debug("inventory->ui", "OpenInventory", "item.id", item.id);
        logger.debug("inventory->ui", "OpenInventory", "amount", amount);

        local label = item:getLabel();
        logger.debug("inventory->ui", "OpenInventory", "label", label);
        local itemEntry = UI.CreateItem(amount .. "x" .. label, "");
        menu:AddItem(itemEntry);

        local itemMenu = UI.CreateMenu(label, "");
    
        if item:getIsUsable() then
            --logger.debug("inventory->ui", "adding use item");
            local useItem = UI.CreateItem("Benutzen", "");
            itemMenu:AddItem(useItem);

            useItem.Activated = function()
                item:use();
                itemMenu:Visible(false);
                OpenInventory(inventory);
            end;
        end

        if item:getIsDroppable() then
            --logger.debug("inventory->ui", "adding drop item");
            local dropItem = UI.CreateItem("Fallen lassen", "");
            itemMenu:AddItem(dropItem);

            dropItem.Activated = function()
                item:drop();
            end;
        end

        item:onMenuBuild(itemMenu);

        menu:BindMenuToItem(itemMenu, itemEntry);
        menu:AddItem(itemMenu);
    end

    menu:Visible(true);
    menu:RefreshIndex();
end