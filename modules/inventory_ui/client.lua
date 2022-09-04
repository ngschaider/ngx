local User = M("user");
local UI = M("UI");
local logger = M("logger");

local pool = UI.CreatePool();

Citizen.CreateThread(function()
    while true do
        pool:ProcessMenus();
        Citizen.Wait(0);
    end
end);

RegisterCommand("inventory", function()
    OpenOwnCharacterInventory();
end);
RegisterKeyMapping("inventory", "Inventar öffnen", "keyboard", "F2");

function OpenOwnCharacterInventory()
    local user = User:GetSelf();
    logger.debug("OpenOwnCharacterInventory", "user", user);
    local character = user:getCurrentCharacter();
    logger.debug("OpenOwnCharacterInventory", "character", character);
    if not character then
        logger.debug("returning");
        return
    end
    logger.debug("getting inv");
    local inventory = character:getInventory();
    logger.debug("OpenOwnCharacterInventory", "inventory", inventory);
    OpenInventory(inventory);
end;

function OpenInventory(inventory)
    logger.debug("creating menu");
    local menu = UI.CreateMenu("Inventar", "");
    logger.debug("clearing pool");
    pool:Clear();
    logger.debug("adding menu");
    pool:Add(menu);
    logger.debug("menu added");

    logger.debug("OpenInventory", "inventory.id", inventory.id);
    local items = inventory:getItems();
    logger.debug("OpenInventory", "#items", #items);
    for _,item in pairs(items) do
        logger.debug("OpenInventory", "item", item);
        logger.debug("OpenInventory", "item.id", item.id);
        local label = item:getLabel();
        logger.debug("OpenInventory", "label", label);
        local itemEntry = UI.CreateItem(label, "");
        menu:AddItem(itemEntry);

        local itemMenu = GetItemMenu(item);
        pool:Add(itemMenu);
        menu:BindMenuToItem(itemMenu, itemEntry);
        menu:AddItem(itemMenu);
    end

    menu:Visible(true);
    pool:RefreshIndex();
	pool:MouseEdgeEnabled(false);
end


function GetItemMenu(item)
    local name = item:getName();
    local menu = UI.CreateMenu(name, "");
    logger.debug("GetItemMenu", "name", name);
    
    if item:getIsUsable() then
        logger.debug("adding use item");
        local useItem = UI.CreateItem("Benutzen", "");
        menu:AddItem(useItem);

        useItem.Activated = function()
            item.use();
        end;
    end

    logger.debug("adding drop item");
    local dropItem = UI.CreateItem("Fallen lassen", "");
    menu:AddItem(dropItem);

    return menu;
end