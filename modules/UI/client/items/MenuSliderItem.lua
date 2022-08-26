MenuSliderItem = setmetatable({}, MenuSliderItem)
MenuSliderItem.__index = MenuSliderItem
MenuSliderItem.__call = function() return "MenuItem", "MenuSliderItem" end

function MenuSliderItem.New(Text, Items, Index, Description, Divider)
	if type(Items) ~= "table" then Items = {} end
	if Index == 0 then Index = 1 end
	local _MenuSliderItem = {
		Base = MenuItem.New(Text or "", Description or ""),
		Items = Items,
		ShowDivider = tobool(Divider),
		LeftArrow = Sprite:new("commonmenutu", "arrowleft", 0, 105, 15, 15),
		RightArrow = Sprite:new("commonmenutu", "arrowright", 0, 105, 15, 15),
		Background = ResRectangle:new(0, 0, 150, 9, 4, 32, 57, 255),
		Slider = ResRectangle:new(0, 0, 75, 9, 57, 116, 200, 255),
		Divider = ResRectangle:new(0, 0, 2.5, 20, 245, 245, 245, 255),
		_Index = tonumber(Index) or 1,
		OnSliderChanged = function(menu, item, newindex) end,
		OnSliderSelected = function(menu, item, newindex) end,
	}
	return setmetatable(_MenuSliderItem, MenuSliderItem)
end

function MenuSliderItem:SetParentMenu(Menu)
	if Menu() == "Menu" then
		self.base.ParentMenu = Menu
	else
		return self.base.ParentMenu
	end
end

function MenuSliderItem:position(Y)
	if tonumber(Y) then
		self.background:position(250 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, Y + 158.5 + self.base._Offset.Y)
		self.slider:position(250 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, Y + 158.5 + self.base._Offset.Y)
		self.divider:position(323.5 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, Y + 153 + self.base._Offset.Y)
		self.leftArrow:position(235 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, 155.5 + Y + self.base._Offset.Y)
		self.rightArrow:position(400 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, 155.5 + Y + self.base._Offset.Y)
		self.base:position(Y)
	end
end

function MenuSliderItem:selected(bool)
	if bool ~= nil then
		self.base._Selected = tobool(bool)
	else
		return self.base._Selected
	end
end

function MenuSliderItem:hovered(bool)
	if bool ~= nil then
		self.base._Hovered = tobool(bool)
	else
		return self.base._Hovered
	end
end

function MenuSliderItem:enabled(bool)
	if bool ~= nil then
		self.base._Enabled = tobool(bool)
	else
		return self.base._Enabled
	end
end

function MenuSliderItem:description(str)
	if tostring(str) and str ~= nil then
		self.base._Description = tostring(str)
	else
		return self.base._Description
	end
end

function MenuSliderItem:Offset(X, Y)
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

function MenuSliderItem:Text(Text)
	if tostring(Text) and Text ~= nil then
		self.base.text:Text(tostring(Text))
	else
		return self.base.text:Text()
	end
end

function MenuSliderItem:Index(Index)
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

function MenuSliderItem:ItemToIndex(Item)
	for i = 1, #self.items do
		if type(Item) == type(self.items[i]) and Item == self.items[i] then
			return i
		end
	end
end

function MenuSliderItem:IndexToItem(Index)
	if tonumber(Index) then
		if tonumber(Index) == 0 then Index = 1 end
		if self.items[tonumber(Index)] then
			return self.items[tonumber(Index)]
		end
	end
end

function MenuSliderItem:SetLeftBadge()
	error("This item does not support badges")
end

function MenuSliderItem:SetRightBadge()
	error("This item does not support badges")
end

function MenuSliderItem:RightLabel()
	error("This item does not support a right label")
end

function MenuSliderItem:draw()
	self.base:draw()

	if self:enabled() then
		if self:selected() then
			self.leftArrow:color(0, 0, 0, 255)
			self.rightArrow:color(0, 0, 0, 255)
		else
			self.leftArrow:color(245, 245, 245, 255)
			self.rightArrow:color(245, 245, 245, 255)
		end
	else
		self.leftArrow:color(163, 159, 148, 255)
		self.rightArrow:color(163, 159, 148, 255)
	end
	
	local Offset = ((self.background.Width - self.slider.Width)/(#self.items - 1)) * (self._Index-1)

	self.slider:position(250 + self.base._Offset.X + Offset + self.base.ParentMenu.WidthOffset, self.slider.Y)

	if self:selected() then
		self.leftArrow:draw()
		self.rightArrow:draw()
	end

	self.background:draw()
	self.slider:draw()
	if self.showDivider then
		self.divider:draw()
	end
end