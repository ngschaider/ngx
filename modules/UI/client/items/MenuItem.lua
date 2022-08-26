MenuItem = setmetatable({}, MenuItem)
MenuItem.__index = MenuItem
MenuItem.__call = function() return "MenuItem", "MenuItem" end

function MenuItem.New(Text, Description)
	_MenuItem = {
		Rectangle = ResRectangle:new(0, 0, 431, 38, 255, 255, 255, 20),
		Text = ResText:new(tostring(Text) or "", 8, 0, 0.33, 245, 245, 245, 255, 0),
		_Description = tostring(Description) or "";
		SelectedSprite = Sprite:new("commonmenu", "gradient_nav", 0, 0, 431, 38),
		LeftBadge = { Sprite = Sprite:new("commonmenu", "", 0, 0, 40, 40), Badge = 0},
		RightBadge = { Sprite = Sprite:new("commonmenu", "", 0, 0, 40, 40), Badge = 0},
		Label = {
            Text = ResText:new("", 0, 0, 0.35, 245, 245, 245, 255, 0, "Right"),
            MainColor = {R = 255, G = 255, B = 255, A = 255},
            HighlightColor = {R = 0, G = 0, B = 0, A = 255},
        },
		_Selected = false,
		_Hovered = false,
		_Enabled = true,
		_Offset = {X = 0, Y = 0},
		ParentMenu = nil,
		Panels = {},
		Activated = function(menu, item) end,
		ActivatedPanel = function(menu, item, panel, panelvalue) end,
	}
	return setmetatable(_MenuItem, MenuItem)
end

function MenuItem:SetParentMenu(Menu)
    if Menu ~= nil and Menu() == "Menu" then
        self.parentMenu = Menu
    else
        return self.parentMenu
    end
end

function MenuItem:selected(bool)
	if bool ~= nil then
		self._Selected = tobool(bool)
	else
		return self._Selected
	end
end

function MenuItem:hovered(bool)
	if bool ~= nil then
		self._Hovered = tobool(bool)
	else
		return self._Hovered
	end
end

function MenuItem:enabled(bool)
	if bool ~= nil then
		self._Enabled = tobool(bool)
	else
		return self._Enabled
	end
end

function MenuItem:description(str)
	if tostring(str) and str ~= nil then
		self._Description = tostring(str)
	else
		return self._Description
	end
end

function MenuItem:Offset(X, Y)
	if tonumber(X) or tonumber(Y) then
		if tonumber(X) then
			self._Offset.X = tonumber(X)
		end
		if tonumber(Y) then
			self._Offset.Y = tonumber(Y)
		end
	else
		return self._Offset
	end
end

function MenuItem:position(Y)
	if tonumber(Y) then
		self.rectangle:position(self._Offset.X, Y + 144 + self._Offset.Y)
		self.selectedSprite:position(0 + self._Offset.X, Y + 144 + self._Offset.Y)
		self.text:position(8 + self._Offset.X, Y + 147 + self._Offset.Y)
		self.leftBadge.Sprite:position(0 + self._Offset.X, Y + 142 + self._Offset.Y)
		self.rightBadge.Sprite:position(385 + self._Offset.X, Y + 142 + self._Offset.Y)
		self.label.text:position(420 + self._Offset.X, Y + 148 + self._Offset.Y)
	end
end

function MenuItem:RightLabel(Text, MainColor, HighlightColor)
	if tostring(Text) and Text ~= nil then
        if type(MainColor) == "table" then
            self.label.MainColor = MainColor
        end
        if type(HighlightColor) == "table" then
            self.label.HighlightColor = HighlightColor
        end
		self.label.text:Text(tostring(Text))
	else
		return self.label.text:Text()
	end
end

function MenuItem:SetLeftBadge(Badge)
	if tonumber(Badge) then
		self.leftBadge.Badge = tonumber(Badge)
	end
end

function MenuItem:SetRightBadge(Badge)
	if tonumber(Badge) then
		self.rightBadge.Badge = tonumber(Badge)
	end
end

function MenuItem:Text(Text)
	if tostring(Text) and Text ~= nil then
		self.text:Text(tostring(Text))
	else
		return self.text:Text()
	end
end

function MenuItem:AddPanel(Panel)
	if Panel() == "MenuPanel" then
		table.insert(self.panels, Panel)
		Panel:SetParentItem(self)
	end
end

function MenuItem:RemovePanelAt(Index)
	if tonumber(Index) then
		if self.panels[Index] then
			table.remove(self.panels, tonumber(Index))
		end
	end
end

function MenuItem:FindPanelIndex(Panel)
	if Panel() == "MenuPanel" then
		for Index = 1, #self.panels do
			if self.panels[Index] == Panel then
				return Index
			end
		end
	end
	return nil
end

function MenuItem:FindPanelItem()
	for Index = #self.items, 1, -1 do
		if self.items[Index].Panel then
			return Index
		end
	end
	return nil
end

function MenuItem:draw()
	self.rectangle:Size(431 + self.parentMenu.WidthOffset, self.rectangle.height)
	self.selectedSprite:Size(431 + self.parentMenu.WidthOffset, self.selectedSprite.height)

	if self._Hovered and not self._Selected then
		self.rectangle:draw()
	end

	if self._Selected then
		self.selectedSprite:draw()
	end

	if self._Enabled then
		if self._Selected then
			self.text:color(0, 0, 0, 255)
			self.label.text:color(self.label.HighlightColor.R, self.label.HighlightColor.G, self.label.HighlightColor.B, self.label.HighlightColor.A)
		else
			self.text:color(245, 245, 245, 255)
			self.label.text:color(self.label.MainColor.R, self.label.MainColor.G, self.label.MainColor.B, self.label.MainColor.A)
		end
	else
		self.text:color(163, 159, 148, 255)
        self.label.text:color(163, 159, 148, 255)
	end

	if self.leftBadge.Badge == BadgeStyle.None then
		self.text:position(8 + self._Offset.X, self.text.Y)
	else
		self.text:position(35 + self._Offset.X, self.text.Y)
		self.leftBadge.Sprite.TxtDictionary = GetBadgeDictionary(self.leftBadge.Badge, self._Selected)
		self.leftBadge.Sprite.TxtName = GetBadgeTexture(self.leftBadge.Badge, self._Selected)
		self.leftBadge.Sprite:color(GetBadgeColor(self.leftBadge.Badge, self._Selected))
		self.leftBadge.Sprite:draw()
	end

	if self.rightBadge.Badge ~= BadgeStyle.None then
		self.rightBadge.Sprite:position(385 + self._Offset.X + self.parentMenu.WidthOffset, self.rightBadge.Sprite.Y)
		self.rightBadge.Sprite.TxtDictionary = GetBadgeDictionary(self.rightBadge.Badge, self._Selected)
		self.rightBadge.Sprite.TxtName = GetBadgeTexture(self.rightBadge.Badge, self._Selected)
		self.rightBadge.Sprite:color(GetBadgeColor(self.rightBadge.Badge, self._Selected))
		self.rightBadge.Sprite:draw()
	end

	if self.label.text:Text() ~= "" and string.len(self.label.text:Text()) > 0 then
		self.label.text:position(420 + self._Offset.X + self.parentMenu.WidthOffset, self.label.text.Y)
		self.label.text:draw()
	end

	self.text:draw()
end