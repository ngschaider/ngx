local class = M("class");

local MenuPool = class("MenuPool");

function MenuPool:initialize()
	self.menus = {};
end

function MenuPool:AddSubMenu(Menu, Text, Description, KeepPosition, KeepBanner)
	if Menu() == "Menu" then
		local Item = MenuItem.New(tostring(Text), Description or "");
		Menu:AddItem(Item);
		local SubMenu;
		if KeepPosition then
			SubMenu = Menu.New(Menu.Title:Text(), Text, Menu.Position.X, Menu.Position.Y);
		else
			SubMenu = Menu.New(Menu.Title:Text(), Text);
		end
		if KeepBanner then
			if Menu.Logo ~= nil then
				SubMenu.Logo = Menu.Logo;
			else
				SubMenu.Logo = nil;
				SubMenu.Banner = Menu.Banner;
			end
		end
		self:Add(SubMenu);
		Menu:BindMenuToItem(SubMenu, Item);
		return SubMenu;
	end
end

function MenuPool:Add(Menu)
	if Menu() == "Menu" then
		table.insert(self.menus, Menu);
	end
end

function MenuPool:MouseEdgeEnabled(bool)
	if bool ~= nil then
		for _, Menu in pairs(self.menus) do
			Menu.Settings.MouseEdgeEnabled = tobool(bool);
		end
	end
end

function MenuPool:ControlDisablingEnabled(bool)
	if bool ~= nil then
		for _, Menu in pairs(self.menus) do
			Menu.Settings.ControlDisablingEnabled = tobool(bool);
		end
	end
end

function MenuPool:ResetCursorOnOpen(bool)
	if bool ~= nil then
		for _, Menu in pairs(self.menus) do
			Menu.Settings.ResetCursorOnOpen = tobool(bool);
		end
	end
end

function MenuPool:multilineFormats(bool)
	if bool ~= nil then
		for _, Menu in pairs(self.menus) do
			Menu.Settings.multilineFormats = tobool(bool);
		end
	end
end

function MenuPool:Audio(Attribute, Setting)
	if Attribute ~= nil and Setting ~= nil then
		for _, Menu in pairs(self.menus) do
			if Menu.Settings.Audio[Attribute] then
				Menu.Settings.Audio[Attribute] = Setting;
			end
		end
	end
end

function MenuPool:WidthOffset(offset)
	if tonumber(offset) then
		for _, Menu in pairs(self.menus) do
			Menu:SetMenuWidthOffset(tonumber(offset));
		end
	end
end

function MenuPool:CounterPreText(str)
	if str ~= nil then
		for _, Menu in pairs(self.menus) do
			Menu.PageCounter.PreText = tostring(str);
		end
	end
end

function MenuPool:DisableInstructionalButtons(bool)
	if bool ~= nil then
		for _, Menu in pairs(self.menus) do
			Menu.Settings.InstructionalButtons = tobool(bool);
		end
	end
end

function MenuPool:MouseControlsEnabled(bool)
    if bool ~= nil then
        for _, Menu in pairs(self.menus) do
            Menu.Settings.MouseControlsEnabled = tobool(bool);
        end
    end
end

function MenuPool:RefreshIndex()
	for _, Menu in pairs(self.menus) do
		Menu:RefreshIndex();
	end
end

function MenuPool:processMenus();
	self:ProcessControl();
	self:processMouse();
	self:draw();
end

function MenuPool:ProcessControl()
	for _, Menu in pairs(self.menus) do
		if Menu:Visible() then
			Menu:ProcessControl();
		end
	end
end

function MenuPool:processMouse()
	for _, Menu in pairs(self.menus) do
		if Menu:Visible() then
			Menu:processMouse();
		end
	end
end

function MenuPool:draw()
	for _, Menu in pairs(self.menus) do
		if Menu:Visible() then
			Menu:draw();
		end
	end
end

function MenuPool:IsAnyMenuOpen()
	for _, menu in pairs(self.menus) do
		if menu:Visible() then
			return true;
		end
	end
	return false;
end

function MenuPool:CloseAllMenus()
	for _, Menu in pairs(self.menus) do
		if Menu:Visible() then
			Menu:Visible(false);
			Menu.OnMenuClosed(Menu);
		end
	end
end

function MenuPool:SetBannerSprite(Sprite)
	if Sprite() == "Sprite" then
		for _, Menu in pairs(self.menus) do
			Menu:SetBannerSprite(Sprite);
		end
	end
end

function MenuPool:SetBannerRectangle(Rectangle)
	if Rectangle() == "Rectangle" then
		for _, Menu in pairs(self.menus) do
			Menu:SetBannerRectangle(Rectangle);
		end
	end
end

function MenuPool:TotalItemsPerPage(Value)
    if tonumber(Value) then
        for _, Menu in pairs(self.menus) do
            Menu.Pagination.total = Value - 1;
        end
    end
end

module.MenuPool = MenuPool;