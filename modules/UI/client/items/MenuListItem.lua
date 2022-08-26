MenuListItem = setmetatable({}, MenuListItem)
MenuListItem.__index = MenuListItem
MenuListItem.__call = function() return "MenuItem", "MenuListItem" end

function MenuListItem.New(Text, Items, Index, Description)
	if type(Items) ~= "table" then Items = {} end
	if Index == 0 then Index = 1 end
	local _MenuListItem = {
		Base = MenuItem.New(Text or "", Description or ""),
		Items = Items,
		LeftArrow = Sprite:new("commonmenu", "arrowleft", 110, 105, 30, 30),
		RightArrow = Sprite:new("commonmenu", "arrowright", 280, 105, 30, 30),
		ItemText = ResText:new("", 290, 104, 0.35, 255, 255, 255, 255, 0, "Right"),
		_Index = tonumber(Index) or 1,
		Panels = {},
		OnListChanged = function(menu, item, newindex) end,
		OnListSelected = function(menu, item, newindex) end,
	}
	return setmetatable(_MenuListItem, MenuListItem)
end

function MenuListItem:SetParentMenu(Menu)
	if Menu ~= nil and Menu() == "Menu" then
		self.base.ParentMenu = Menu
	else
		return self.base.ParentMenu
	end
end

function MenuListItem:position(Y)
	if tonumber(Y) then
		self.leftArrow:position(300 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, 147 + Y + self.base._Offset.Y)
		self.rightArrow:position(400 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, 147 + Y + self.base._Offset.Y)
		self.itemText:position(300 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, 147 + Y + self.base._Offset.Y)
		self.base:position(Y)
	end
end

function MenuListItem:selected(bool)
	if bool ~= nil then
		self.base._Selected = tobool(bool)
	else
		return self.base._Selected
	end
end

function MenuListItem:hovered(bool)
	if bool ~= nil then
		self.base._Hovered = tobool(bool)
	else
		return self.base._Hovered
	end
end

function MenuListItem:enabled(bool)
	if bool ~= nil then
		self.base._Enabled = tobool(bool)
	else
		return self.base._Enabled
	end
end

function MenuListItem:description(str)
	if tostring(str) and str ~= nil then
		self.base._Description = tostring(str)
	else
		return self.base._Description
	end
end

function MenuListItem:Offset(X, Y)
	if tonumber(X) or tonumber(Y) then
		if tonumber(X) then
			self.base._Offset.X = tonumber(X)
		end
		if tonumber(Y) then
			self.base._Offset.Y = tonumber(Y)
		end
	else
		return self.base._Offset
	end
end

function MenuListItem:Text(Text)
	if tostring(Text) and Text ~= nil then
		self.base.text:Text(tostring(Text))
	else
		return self.base.text:Text()
	end
end

function MenuListItem:Index(Index)
	if tonumber(Index) then
		if tonumber(Index) > #self.items then
			self._Index = 1
		elseif tonumber(Index) < 1 then
			self._Index = #self.items
		else
			self._Index = tonumber(Index)
		end
	else
		return self._Index
	end
end

function MenuListItem:ItemToIndex(Item)
	for i = 1, #self.items do
		if type(Item) == type(self.items[i]) and Item == self.items[i] then
			return i
		elseif type(self.items[i]) == "table" and (type(Item) == type(self.items[i].Name) or type(Item) == type(self.items[i].Value)) and (Item == self.items[i].Name or Item == self.items[i].Value) then
			return i
		end
	end
end

function MenuListItem:IndexToItem(Index)
	if tonumber(Index) then
		if tonumber(Index) == 0 then Index = 1 end
		if self.items[tonumber(Index)] then
			return self.items[tonumber(Index)]
		end
	end
end

function MenuListItem:SetLeftBadge()
	error("This item does not support badges")
end

function MenuListItem:SetRightBadge()
	error("This item does not support badges")
end

function MenuListItem:RightLabel()
	error("This item does not support a right label")
end

function MenuListItem:AddPanel(Panel)
	if Panel() == "MenuPanel" then
		table.insert(self.panels, Panel)
		Panel:SetParentItem(self)
	end
end

function MenuListItem:RemovePanelAt(Index)
	if tonumber(Index) then
		if self.panels[Index] then
			table.remove(self.panels, tonumber(Index))
		end
	end
end

function MenuListItem:FindPanelIndex(Panel)
	if Panel() == "MenuPanel" then
		for Index = 1, #self.panels do
			if self.panels[Index] == Panel then
				return Index
			end
		end
	end
	return nil
end

function MenuListItem:FindPanelItem()
	for Index = #self.items, 1, -1 do
		if self.items[Index].Panel then
			return Index
		end
	end
	return nil
end

function MenuListItem:draw()
	self.base:draw()

	if self:enabled() then
		if self:selected() then
			self.itemText:color(0, 0, 0, 255)
			self.leftArrow:color(0, 0, 0, 255)
			self.rightArrow:color(0, 0, 0, 255)
		else
			self.itemText:color(245, 245, 245, 255)
			self.leftArrow:color(245, 245, 245, 255)
			self.rightArrow:color(245, 245, 245, 255)
		end
	else
		self.itemText:color(163, 159, 148, 255)
		self.leftArrow:color(163, 159, 148, 255)
		self.rightArrow:color(163, 159, 148, 255)
	end

	local Text = (type(self.items[self._Index]) == "table") and tostring(self.items[self._Index].Name) or tostring(self.items[self._Index])
	local Offset = MeasureStringWidth(Text, 0, 0.35)

	self.itemText:Text(Text)
	self.leftArrow:position(378 - Offset + self.base._Offset.X + self.base.ParentMenu.WidthOffset, self.leftArrow.Y)

	if self:selected() then
		self.leftArrow:draw()
		self.rightArrow:draw()
		self.itemText:position(403 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, self.itemText.Y)
	else
		self.itemText:position(418 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, self.itemText.Y)
	end

	self.itemText:draw()
end