MenuColoredItem = setmetatable({}, MenuColoredItem)
MenuColoredItem.__index = MenuColoredItem
MenuColoredItem.__call = function() return "MenuItem", "MenuColoredItem" end

function MenuColoredItem.New(Text, Description, MainColor, HighlightColor)
	if type(Color) ~= "table" then Color = {R = 0, G = 0, B = 0, A = 255} end
	if type(HighlightColor) ~= "table" then Color = {R = 255, G = 255, B = 255, A = 255} end
	local _MenuColoredItem = {
		Base = MenuItem.New(Text or "", Description or ""),
		Rectangle = ResRectangle:new(0, 0, 431, 38, MainColor.R, MainColor.G, MainColor.B, MainColor.A),
		MainColor = MainColor,
		HighlightColor = HighlightColor,
		Activated = function(menu, item) end,
	}
	_MenuColoredItem.Base.SelectedSprite:color(HighlightColor.R, HighlightColor.G, HighlightColor.B, HighlightColor.A)
	return setmetatable(_MenuColoredItem, MenuColoredItem)
end

function MenuColoredItem:SetParentMenu(Menu)
	if Menu() == "Menu" then
		self.base.ParentMenu = Menu
	else
		return self.base.ParentMenu
	end
end

function MenuColoredItem:position(Y)
	if tonumber(Y) then
		self.base:position(Y)
		self.rectangle:position(self.base._Offset.X, Y + 144 + self.base._Offset.Y)
	end
end

function MenuColoredItem:selected(bool)
	if bool ~= nil then
		self.base._Selected = tobool(bool)
	else
		return self.base._Selected
	end
end

function MenuColoredItem:hovered(bool)
	if bool ~= nil then
		self.base._Hovered = tobool(bool)
	else
		return self.base._Hovered
	end
end

function MenuColoredItem:enabled(bool)
	if bool ~= nil then
		self.base._Enabled = tobool(bool)
	else
		return self.base._Enabled
	end
end

function MenuColoredItem:description(str)
	if tostring(str) and str ~= nil then
		self.base._Description = tostring(str)
	else
		return self.base._Description
	end
end

function MenuColoredItem:Offset(X, Y)
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

function MenuColoredItem:Text(Text)
	if tostring(Text) and Text ~= nil then
		self.base.text:Text(tostring(Text))
	else
		return self.base.text:Text()
	end
end

function MenuColoredItem:RightLabel(Text, MainColor, HighlightColor)
    if tostring(Text) and Text ~= nil then
        if type(MainColor) == "table" then
            self.base.Label.MainColor = MainColor
        end
        if type(HighlightColor) == "table" then
            self.base.Label.HighlightColor = HighlightColor
        end
        self.base.Label.text:Text(tostring(Text))
    else
        return self.base.Label.text:Text()
    end
end

function MenuColoredItem:SetLeftBadge(Badge)
	if tonumber(Badge) then
		self.base.leftBadge.Badge = tonumber(Badge)
	end
end

function MenuColoredItem:SetRightBadge(Badge)
	if tonumber(Badge) then
		self.base.rightBadge.Badge = tonumber(Badge)
	end
end

function MenuColoredItem:draw()
	self.rectangle:Size(431 + self.parentMenu.WidthOffset, self.rectangle.height)
	self.rectangle:draw()
	self.base:draw()
end