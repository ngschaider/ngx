local event = M("event");
local logger = M("logger");
local userClass = M("user");

local pool = NativeUI.CreatePool();

local GetPlayerListMenu = function()
    local menu = NativeUI.CreateMenu("Spielerliste", "Spielerliste");
    menu.Settings.MouseEdgeEnabled = false;

    local users = userClass.getAllOnline();

    for _,user in pairs(users) do
        local userName = user.getName();

        
        local text = "[" .. user.id .."] " .. userName;

        local character = user.getCurrentCharacter();
        if character then
            text = text .. " (" .. character.getName() .. ")";
        end

        local userItem = NativeUI.CreateItem(text, "");
        menu:AddItem(userItem);
        local userMenu = GetUserMenu(user);
        pool:Add(userMenu);
        menu:BindMenuToItem(userMenu, userItem);
    end

    return menu;
end;

local GetUserMenu = function(user)
    local character = user.getCurrentCharacter();

    if character then
        local reviveItem = NativeUI.CreateItem("Wiederbeleben", "");
        reviveItem.Activated = function()
            callback.trigger("admin:reviveCharacter", function(success)
                if success then
                    userClass.getSelf().showNotification("Charakter " .. character.getName() .. " wurde wiederbelebt");
                else
                    userClass.getSelf().showNotification("Charakter " .. character.getName() .. " konnte nicht wiederbelebt werden");
                end
            end, character.id);
        end;
    end
end;

local OpenMenu = function()
    local selfUser = userClass.getSelf();
    local characterId = selfUser.getCurrentCharacterId();

    if characterId == nil then
        return;
    end

    local menu = NativeUI.CreateMenu("Administration");
    menu.Settings.MouseEdgeEnabled = false;
    pool:Clear();
    pool:Add(menu);
    
    local playerListItem = NativeUI.CreateItem("Spielerliste", "");
    menu:AddItem(playerListItem);
    local playerListMenu = GetPlayerListMenu();
    pool:Add(playerListMenu);
    menu:BindMenuToItem(playerListMenu, playerListItem);
    
    menu:Visible(true);
	pool:RefreshIndex();
end;


event.onServer("admin:OpenMenu", function()
    logger.debug("Opening Admin Menu");
    OpenMenu();
end);

Citizen.CreateThread(function()
    while true do
        pool:ProcessMenus();
        Citizen.Wait(0);
    end
end);