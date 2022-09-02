local User = M("user");
local UI = M("UI");

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
    print("got user", user);
    local character = user:getCurrentCharacter();
    print("got char", character);
    if not character then
        print("returning");
        return
    end
    print("getting inv");
    local inventory = character:getInventory();
    print("got inv");
    OpenInventory(inventory);
end;

function OpenInventory(inventory)
    print("creating menu");
    local menu = UI.CreateMenu("Inventar", "");
    print("clearing pool");
    pool:Clear();
    print("adding menu");
    pool:Add(menu);

    print("getting items");
    local items = inventory:getItems();    
    print("got items");
    for _,item in pairs(items) do
        local name = item:getName();
        local itemEntry = UI.CreateItem(name, "");
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
    print(name);
    
    if item:getIsUsable() then
        print("adding use item");
        local useItem = UI.CreateItem("Benutzen", "");
        menu:AddItem(useItem);

        useItem.Activated = function()
            item.use();
        end;
    end

    print("adding drop item");
    local dropItem = UI.CreateItem("Fallen lassen", "");
    menu:AddItem(dropItem);

    return menu;
end