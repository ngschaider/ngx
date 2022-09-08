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
    logger.debug("inventory_ui", "OpenOwnCharacterInventory", "character", character);
    if not character then
        logger.debug("inventory_ui", "returning");
        return
    end
    logger.debug("inventory_ui", "getting inv");
    local inventory = character:getInventory();
    logger.debug("inventory_ui", "OpenOwnCharacterInventory", "inventory", inventory);
    OpenInventory(inventory);
end;

function OpenInventory(inventory)
    logger.debug("inventory_ui", "creating menu");
    local menu = UI.CreateMenu("Inventar", "");

    logger.debug("inventory_ui", "OpenInventory", "inventory.id", inventory.id);
    local items = inventory:getItems();
    logger.debug("inventory_ui", "OpenInventory", "#items", #items);
    for _,item in pairs(items) do
        logger.debug("inventory_ui", "OpenInventory", "item", item);
        logger.debug("inventory_ui", "OpenInventory", "item.id", item.id);
        local label = item:getLabel();
        logger.debug("inventory_ui", "OpenInventory", "label", label);
        local itemEntry = UI.CreateItem(label, "");
        menu:AddItem(itemEntry);

        local itemMenu = GetItemMenu(inventory, item);
        menu:BindMenuToItem(itemMenu, itemEntry);
        menu:AddItem(itemMenu);
    end

    menu:Visible(true);
    menu:RefreshIndex();
end


function GetItemMenu(inventory, item)
    local menu = UI.CreateMenu(item:getLabel(), "");
    
    if item:getIsUsable() then
        logger.debug("inventory_ui", "adding use item");
        local useItem = UI.CreateItem("Benutzen", "");
        menu:AddItem(useItem);

        useItem.Activated = function()
            item:use();
            menu:Visible(false);
            OpenInventory(inventory);
        end;
    end

    if item:getIsDroppable() then
        logger.debug("inventory_ui", "adding drop item");
        local dropItem = UI.CreateItem("Fallen lassen", "");
        menu:AddItem(dropItem);

        dropItem.Activated = function()
            item:drop();
        end;
    end

    item:onMenuBuild();

    return menu;
end