local event = M("core").event;
local logger = M("core").logger;
local User = M("user");
local UI = M("UI");

local pool = UI.CreatePool();

local GetUserMenu = function(user)
    local character = user:getCurrentCharacter();

    if character then
        local reviveItem = UI.CreateItem("Wiederbeleben", "");
        reviveItem.Activated = function()
            callback.trigger("admin:reviveCharacter", function(success)
                if success then
                    User:GetSelf().showNotification("Charakter " .. character:getName() .. " wurde wiederbelebt");
                else
                    User:GetSelf().showNotification("Charakter " .. character:getName() .. " konnte nicht wiederbelebt werden");
                end
            end, character.id);
        end;
    end
end;

local GetPlayerListMenu = function()
    local menu = UI.CreateMenu("Spielerliste", "Spielerliste");
    menu.Settings.MouseEdgeEnabled = false;

    local users = User:GetAllOnline();

    for _,user in pairs(users) do
        local userName = user:getName();

        local text = "[" .. user.id .."] " .. userName;

        local character = user:getCurrentCharacter();
        if character then
            text = text .. " (" .. character:getName() .. ")";
        end

        local userItem = UI.CreateItem(text, "");
        menu:AddItem(userItem);
        local userMenu = GetUserMenu(user);
        pool:Add(userMenu);
        menu:BindMenuToItem(userMenu, userItem);
    end

    return menu;
end;

local OpenMenu = function()
    local selfUser = User:GetSelf();
    local characterId = selfUser:getCurrentCharacterId();

    if characterId == nil then
        return;
    end

    local menu = UI.CreateMenu("Administration");
    menu.Settings.MouseEdgeEnabled = false;
    pool:Clear();
    pool:Add(menu);
    
    local playerListItem = UI.CreateItem("Spielerliste", "");
    menu:AddItem(playerListItem);
    local playerListMenu = GetPlayerListMenu();
    pool:Add(playerListMenu);
    menu:BindMenuToItem(playerListMenu, playerListItem);
    
    menu:Visible(true);
	pool:RefreshIndex();
end;


event.on("admin:OpenMenu", function()
    logger.debug("admin", "admin:OpenMenu");
    OpenMenu();
end);