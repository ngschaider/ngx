MenuCheckboxItem = setmetatable({}, MenuCheckboxItem)
MenuCheckboxItem.__index = MenuCheckboxItem
MenuCheckboxItem.__call = function() return "MenuItem", "MenuCheckboxItem" end

function MenuCheckboxItem.New(Text, Check, Description)
	local _MenuCheckboxItem = {
		Base = MenuItem.New(Text or "", Description or ""),
		CheckedSprite = Sprite:new("commonmenu", "shop_box_blank", 410, 95, 50, 50),
		Checked = tobool(Check),
		CheckboxEvent = function(menu, item, checked) end,
	}
	return setmetatable(_MenuCheckboxItem, MenuCheckboxItem)
end

function MenuCheckboxItem:SetParentMenu(Menu)
	if Menu() == "Menu" then
		self.base.ParentMenu = Menu
	else
		return self.base.ParentMenu
	end
end

function MenuCheckboxItem:position(Y)
	if tonumber(Y) then
		self.base:position(Y)
		self.checkedSprite:position(380 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, Y + 138 + self.base._Offset.Y)
	end
end

function MenuCheckboxItem:selected(bool)
	if bool ~= nil then
		self.base._Selected = tobool(bool)
	else
		return self.base._Selected
	end
end

function MenuCheckboxItem:hovered(bool)
	if bool ~= nil then
		self.base._Hovered = tobool(bool)
	else
		return self.base._Hovered
	end
end

function MenuCheckboxItem:enabled(bool)
	if bool ~= nil then
		self.base._Enabled = tobool(bool)
	else
		return self.base._Enabled
	end
end

function MenuCheckboxItem:description(str)
	if tostring(str) and str ~= nil then
		self.base._Description = tostring(str)
	else
		return self.base._Description
	end
end

function MenuCheckboxItem:Offset(X, Y)
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

function MenuCheckboxItem:Text(Text)
	if tostring(Text) and Text ~= nil then
		self.base.text:Text(tostring(Text))
	else
		return self.base.text:Text()
	end
end

function MenuCheckboxItem:SetLeftBadge()
	error("This item does not support badges")
end

function MenuCheckboxItem:SetRightBadge()
	error("This item does not support badges")
end

function MenuCheckboxItem:RightLabel()
	error("This item does not support a right label")
end

function MenuCheckboxItem:draw()
	self.base:draw()
	self.checkedSprite:position(380 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, self.checkedSprite.Y)
	if self.base:selected() then
		if self.checked then
			self.checkedSprite.TxtName = "shop_box_tickb"
		else
			self.checkedSprite.TxtName = "shop_box_blankb"
		end
	else
		if self.checked then
			self.checkedSprite.TxtName = "shop_box_tick"
		else
			self.checkedSprite.TxtName = "shop_box_blank"
		end
	end
	self.checkedSprite:draw()
end