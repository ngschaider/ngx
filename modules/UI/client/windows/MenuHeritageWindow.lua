MenuHeritageWindow = setmetatable({}, MenuHeritageWindow)
MenuHeritageWindow.__index = MenuHeritageWindow
MenuHeritageWindow.__call = function() return "MenuWindow", "MenuHeritageWindow" end

function MenuHeritageWindow.New(Mum, Dad)
	if not tonumber(Mum) then Mum = 0 end
	if not (Mum >= 0 and Mum <= 21) then Mum = 0 end
	if not tonumber(Dad) then Dad = 0 end
	if not (Dad >= 0 and Dad <= 23) then Dad = 0 end
	_MenuHeritageWindow = {
		Background = Sprite:new("pause_menu_pages_char_mom_dad", "mumdadbg", 0, 0, 431, 228), -- Background is required, must be a sprite or a rectangle.
		MumSprite = Sprite:new("char_creator_portraits", ((Mum < 21) and "female_"..Mum or "special_female_"..(tonumber(string.sub(Mum, 2, 2)) - 1)), 0, 0, 228, 228),
		DadSprite = Sprite:new("char_creator_portraits", ((Dad < 21) and "male_"..Dad or "special_male_"..(tonumber(string.sub(Dad, 2, 2)) - 1)), 0, 0, 228, 228),
		Mum = Mum,
		Dad = Dad,
		_Offset = {X = 0, Y = 0}, -- required
		ParentMenu = nil, -- required
	}
	return setmetatable(_MenuHeritageWindow, MenuHeritageWindow)
end

function MenuHeritageWindow:SetParentMenu(Menu) -- required
	if Menu() == "Menu" then
		self.parentMenu = Menu
	else
		return self.parentMenu
	end
end

function MenuHeritageWindow:Offset(X, Y) -- required
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

function MenuHeritageWindow:position(Y) -- required
    if tonumber(Y) then
        self.background:position(self._Offset.X, 144 + Y + self._Offset.Y)
        self.mumSprite:position(self._Offset.X + (self.parentMenu.WidthOffset/2) + 25, 144 + Y + self._Offset.Y)
        self.dadSprite:position(self._Offset.X + (self.parentMenu.WidthOffset/2) + 195, 144 + Y + self._Offset.Y)
    end
end

function MenuHeritageWindow:Index(Mum, Dad)
	if not tonumber(Mum) then Mum = self.mum end
	if not (Mum >= 0 and Mum <= 21) then Mum = self.mum end
	if not tonumber(Dad) then Dad = self.dad end
	if not (Dad >= 0 and Dad <= 23) then Dad = self.dad end

	self.mum = Mum
	self.dad = Dad

	self.mumSprite.TxtName = ((self.mum < 21) and "female_"..self.mum or "special_female_"..(tonumber(string.sub(Mum, 2, 2)) - 1))
	self.dadSprite.TxtName = ((self.dad < 21) and "male_"..self.dad or "special_male_"..(tonumber(string.sub(Dad, 2, 2)) - 1))
end

function MenuHeritageWindow:draw() -- required
	self.background:Size(431 + self.parentMenu.WidthOffset, 228)
	self.background:draw()
	self.dadSprite:draw()
	self.mumSprite:draw()
end