MenuProgressItem = setmetatable({}, MenuProgressItem)
MenuProgressItem.__index = MenuProgressItem
MenuProgressItem.__call = function() return "MenuItem", "MenuProgressItem" end

function MenuProgressItem.New(Text, Items, Index, Description, Counter)
	if type(Items) ~= "table" then Items = {} end
	if Index == 0 then Index = 1 end
	local _MenuProgressItem = {
		Base = MenuItem.New(Text or "", Description or ""),
		Data = {
			Items = Items,
			Counter = tobool(Counter),
			Max = 407.5,
			Index = tonumber(Index) or 1,
		},
		Background = ResRectangle:new(0, 0, 415, 20),
		Bar = ResRectangle:new(0, 0, 407.5, 12.5),
		onProgressChanged = function(menu, item, newindex) end,
		OnProgressSelected = function(menu, item, newindex) end,
	}

	_MenuProgressItem.Base.rectangle.height = 60
	_MenuProgressItem.Base.SelectedSprite.height = 60

	if _MenuProgressItem.Data.Counter then
		_MenuProgressItem.Base:RightLabel(_MenuProgressItem.Data.Index.."/"..#_MenuProgressItem.Data.Items)
	else
		_MenuProgressItem.Base:RightLabel((type(_MenuProgressItem.Data.Items[_MenuProgressItem.Data.Index]) == "table") and tostring(_MenuProgressItem.Data.Items[_MenuProgressItem.Data.Index].Name) or tostring(_MenuProgressItem.Data.Items[_MenuProgressItem.Data.Index]))
	end

	_MenuProgressItem.bar.Width = _MenuProgressItem.Data.Index/#_MenuProgressItem.Data.Items * _MenuProgressItem.Data.max

	return setmetatable(_MenuProgressItem, MenuProgressItem)
end

function MenuProgressItem:SetParentMenu(Menu)
	if Menu() == "Menu" then
		self.base.ParentMenu = Menu
	else
		return self.base.ParentMenu
	end
end

function MenuProgressItem:position(Y)
	if tonumber(Y) then
		self.base:position(Y)
		self.background:position(8 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, 177 + Y + self.base._Offset.Y)
		self.bar:position(11.75 + self.base._Offset.X + self.base.ParentMenu.WidthOffset, 180.75 + Y + self.base._Offset.Y)
	end
end

function MenuProgressItem:selected(bool)
	if bool ~= nil then
		self.base._Selected = tobool(bool)
	else
		return self.base._Selected
	end
end

function MenuProgressItem:hovered(bool)
	if bool ~= nil then
		self.base._Hovered = tobool(bool)
	else
		return self.base._Hovered
	end
end

function MenuProgressItem:enabled(bool)
	if bool ~= nil then
		self.base._Enabled = tobool(bool)
	else
		return self.base._Enabled
	end
end

function MenuProgressItem:description(str)
	if tostring(str) and str ~= nil then
		self.base._Description = tostring(str)
	else
		return self.base._Description
	end
end

function MenuProgressItem:Offset(X, Y)
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

function MenuProgressItem:Text(Text)
	if tostring(Text) and Text ~= nil then
		self.base.text:Text(tostring(Text))
	else
		return self.base.text:Text()
	end
end

function MenuProgressItem:Index(Index)
	if tonumber(Index) then
		if tonumber(Index) > #self.data.Items then
			self.data.Index = 1
		elseif tonumber(Index) < 1 then
			self.data.Index = #self.data.Items
		else
			self.data.Index = tonumber(Index)
		end

		if self.data.Counter then
			self.base:RightLabel(self.data.Index.."/"..#self.data.Items)
		else
			self.base:RightLabel((type(self.data.Items[self.data.Index]) == "table") and tostring(self.data.Items[self.data.Index].Name) or tostring(self.data.Items[self.data.Index]))
		end

		self.bar.Width = self.data.Index/#self.data.Items * self.data.max
	else
		return self.data.Index
	end
end

function MenuProgressItem:ItemToIndex(Item)
	for i = 1, #self.data.Items do
		if type(Item) == type(self.data.Items[i]) and Item == self.data.Items[i] then
			return i
		elseif type(self.data.Items[i]) == "table" and (type(Item) == type(self.data.Items[i].Name) or type(Item) == type(self.data.Items[i].Value)) and (Item == self.data.Items[i].Name or Item == self.data.Items[i].Value) then
			return i
		end
	end
end

function MenuProgressItem:IndexToItem(Index)
	if tonumber(Index) then
		if tonumber(Index) == 0 then Index = 1 end
		if self.data.Items[tonumber(Index)] then
			return self.data.Items[tonumber(Index)]
		end
	end
end

function MenuProgressItem:SetLeftBadge()
	error("This item does not support badges")
end

function MenuProgressItem:SetRightBadge()
	error("This item does not support badges")
end

function MenuProgressItem:RightLabel()
	error("This item does not support a right label")
end

function MenuProgressItem:CalculateProgress(CursorX)
	local Progress = CursorX - self.bar.X
	self:Index(math.round(#self.data.Items * (((Progress >= 0 and Progress <= self.data.max) and Progress or ((Progress < 0) and 0 or self.data.max))/self.data.max)))
end

function MenuProgressItem:draw()
	self.base:draw()

	if self.base._Selected then
		self.background:color(table.unpack(Colors.Black))
		self.bar:color(table.unpack(Colors.White))
	else
		self.background:color(table.unpack(Colors.White))
		self.bar:color(table.unpack(Colors.Black))
	end

	self.background:draw()
	self.bar:draw()
end