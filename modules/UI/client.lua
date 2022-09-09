run("client/Utils.lua");
run("client/elements/UIResRectangle.lua");
run("client/elements/UIResText.lua");
run("client/elements/Sprite.lua");
run("client/elements/StringMeasurer.lua");
run("client/elements/Badge.lua");
run("client/elements/Colours.lua");
run("client/items/UIMenuItem.lua");
run("client/items/UIMenuCheckboxItem.lua");
run("client/items/UIMenuListItem.lua");
run("client/items/UIMenuSliderItem.lua");
run("client/items/UIMenuColouredItem.lua");
run("client/items/UIMenuprogressItem.lua");
run("client/windows/UIMenuHeritageWindow.lua");
run("client/panels/UIMenuGridPanel.lua");
run("client/panels/UIMenuColourPanel.lua");
run("client/panels/UIMenuPercentagePanel.lua");
run("client/UIMenu.lua");
run("client/MenuPool.lua");

--module.CreatePool = MenuPool.New;
module.CreateMenu = UIMenu.New;
module.CreateItem = UIMenuItem.New;
module.CreateColouredItem = UIMenuColouredItem.New;
module.CreateCheckboxItem = UIMenuCheckboxItem.New;
module.CreateListItem = UIMenuListItem.New;
module.CreateSliderItem = UIMenuSliderItem.New;
module.CreateProgressItem = UIMenuProgressItem.New;
module.CreateHeritageWindow = UIMenuHeritageWindow.New;
module.CreateGridPanel = UIMenuGridPanel.New;
module.CreateColourPanel = UIMenuColourPanel.New;
module.CreatePercentagePanel = UIMenuPercentagePanel.New;
module.CreateSprite = Sprite.New;
module.CreateRectangle = UIResRectangle.New;
module.CreateText = UIResText.New;



local mainPool = MenuPool.New();
RegisterMenu = function(menu)
    mainPool:Add(menu);
end

IsAnyMenuOpen = function()
    return mainPool:IsAnyMenuOpen();
end

Citizen.CreateThread(function()
    while true do
        mainPool:ProcessMenus();
        Citizen.Wait(0);
    end
end);

