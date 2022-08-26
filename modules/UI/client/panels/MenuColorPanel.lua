MenuColorPanel = setmetatable({}, MenuColorPanel)
MenuColorPanel.__index = MenuColorPanel
MenuColorPanel.__call = function() return "MenuPanel", "MenuColorPanel" end

function MenuColorPanel.New(Title, Colors)
	_MenuColorPanel = {
		Data = {
			Pagination = {
				Min = 1,
				Max = 8,
				Total = 8,
			},
			Index = 1000,
			Items = Colors,
			Title = Title or "Title",
			Enabled = true,
			Value = 1,
		},
		Background = Sprite:new("commonmenu", "gradient_bgd", 0, 0, 431, 112),
		Bar = {},
		LeftArrow = Sprite:new("commonmenu", "arrowleft", 0, 0, 30, 30),
		RightArrow = Sprite:new("commonmenu", "arrowright", 0, 0, 30, 30),
		SelectedRectangle = ResRectangle:new(0, 0, 44.5, 8),
		Text = ResText:new(Title.." (1 of "..#Colors..")" or "Title".." (1 of "..#Colors..")", 0, 0, 0.35, 255, 255, 255, 255, 0, "Centre"),
		ParentItem = nil,
	}

	for Index = 1, #Colors do
		if Index < 10 then
			table.insert(_MenuColorPanel.bar, ResRectangle:new(0, 0, 44.5, 44.5, table.unpack(Colors[Index])))
		else
			break
		end
	end

	if #_MenuColorPanel.Data.Items ~= 0 then
		_MenuColorPanel.Data.Index = 1000 - (1000 % #_MenuColorPanel.Data.Items)
		_MenuColorPanel.Data.Pagination.max = _MenuColorPanel.Data.Pagination.total + 1
		_MenuColorPanel.Data.Pagination.min = 0
	end
	return setmetatable(_MenuColorPanel, MenuColorPanel)
end

function MenuColorPanel:SetParentItem(Item) -- required
	if Item() == "MenuItem" then
		self.parentItem = Item
	else
		return self.parentItem
	end
end

function MenuColorPanel:enabled(Enabled)
	if type(Enabled) == "boolean" then
		self.data.enabled = Enabled
	else
		return self.data.enabled
	end
end

function MenuColorPanel:position(Y) -- required
    if tonumber(Y) then
        local ParentOffsetX, ParentOffsetWidth = self.parentItem:Offset().X, self.parentItem:SetParentMenu().WidthOffset

        self.background:position(ParentOffsetX, Y)
        for Index = 1, #self.bar do
            self.bar[Index]:position(15 + (44.5 * (Index - 1)) + ParentOffsetX + (ParentOffsetWidth/2), 55 + Y)
        end
        self.selectedRectangle:position(15 + (44.5 * ((self:currentSelection() - self.data.Pagination.min) - 1)) + ParentOffsetX + (ParentOffsetWidth/2), 47 + Y)
        self.leftArrow:position(7.5 + ParentOffsetX + (ParentOffsetWidth/2), 15 + Y)
        self.rightArrow:position(393.5 + ParentOffsetX + (ParentOffsetWidth/2), 15 + Y)
        self.text:position(215.5 + ParentOffsetX + (ParentOffsetWidth/2), 15 + Y)
    end
end

function MenuColorPanel:currentSelection(value, PreventUpdate)
    if tonumber(value) then
        if #self.data.Items == 0 then
            self.data.Index = 0
        end

        self.data.Index = 1000000 - (1000000 % #self.data.Items) + tonumber(value)

        if self:currentSelection() > self.data.Pagination.max then
            self.data.Pagination.min = self:currentSelection() - (self.data.Pagination.total + 1)
            self.data.Pagination.max = self:currentSelection()
        elseif self:currentSelection() < self.data.Pagination.min then
            self.data.Pagination.min = self:currentSelection() - 1
            self.data.Pagination.max = self:currentSelection() + (self.data.Pagination.total + 1)
        end

        self:UpdateSelection(PreventUpdate)
    else
        if #self.data.Items == 0 then
            return 1
        else
            if self.data.Index % #self.data.Items == 0 then
                return 1
            else
                return self.data.Index % #self.data.Items + 1
            end
        end
    end
end

function MenuColorPanel:UpdateParent(Color)
	local _, ParentType = self.parentItem()
	if ParentType == "MenuListItem" then
		local PanelItemIndex = self.parentItem:FindPanelItem()
		local PanelIndex = self.parentItem:FindPanelIndex(self)
		if PanelItemIndex then
			self.parentItem.Items[PanelItemIndex].Value[PanelIndex] = Color
			self.parentItem:Index(PanelItemIndex)
			self.parentItem.Base.ParentMenu.OnListChange(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
			self.parentItem.OnListChanged(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
		else
			for Index = 1, #self.parentItem.Items do
				if type(self.parentItem.Items[Index]) == "table" then
					if not self.parentItem.Items[Index].panels then self.parentItem.Items[Index].panels = {} end
					self.parentItem.Items[Index].panels[PanelIndex] = Color
				else
					self.parentItem.Items[Index] = {Name = tostring(self.parentItem.Items[Index]), Value = self.parentItem.Items[Index], Panels = {[PanelIndex] = Color}}
				end
			end
			self.parentItem.Base.ParentMenu.OnListChange(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
			self.parentItem.OnListChanged(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)		
		end
	elseif ParentType == "MenuItem" then
		self.parentItem.ActivatedPanel(self.parentItem.ParentMenu, self.parentItem, self, Color)
	end
end

function MenuColorPanel:UpdateSelection(PreventUpdate)
    local currentSelection = self:currentSelection()
    if not PreventUpdate then
        self:UpdateParent(currentSelection)
    end
    self.selectedRectangle:position(15 + (44.5 * ((currentSelection - self.data.Pagination.min) - 1)) + self.parentItem:Offset().X, self.selectedRectangle.Y)
    for Index = 1, 9 do
        self.bar[Index]:color(table.unpack(self.data.Items[self.data.Pagination.min + Index]))
    end
    self.text:Text(self.data.Title.." ("..currentSelection.." of "..#self.data.Items..")")
end

function MenuColorPanel:Functions()

    local SafeZone = {X = 0, Y = 0}
    if self.parentItem:SetParentMenu().Settings.ScaleWithSafezone then
	   SafeZone = GetSafeZoneBounds()
    end


	if IsMouseInBounds(self.leftArrow.X + SafeZone.X, self.leftArrow.Y + SafeZone.Y, self.leftArrow.Width, self.leftArrow.height) then
		if IsDisabledControlJustPressed(0, 24) then
			if #self.data.Items > self.data.Pagination.total + 1 then
				if self:currentSelection() <= self.data.Pagination.min + 1 then
					if self:currentSelection() == 1 then
						self.data.Pagination.min = #self.data.Items - (self.data.Pagination.total + 1)
						self.data.Pagination.max = #self.data.Items
						self.data.Index = 1000 - (1000 % #self.data.Items)
						self.data.Index = self.data.Index + (#self.data.Items - 1)
						self:UpdateSelection()
					else
						self.data.Pagination.min = self.data.Pagination.min - 1
						self.data.Pagination.max = self.data.Pagination.max - 1
						self.data.Index = self.data.Index - 1
						self:UpdateSelection()
					end
				else
					self.data.Index = self.data.Index - 1
					self:UpdateSelection()
				end
			else
				self.data.Index = self.data.Index - 1
				self:UpdateSelection()
			end
		end
	end

	if IsMouseInBounds(self.rightArrow.X + SafeZone.X, self.rightArrow.Y + SafeZone.Y, self.rightArrow.Width, self.rightArrow.height) then
		if IsDisabledControlJustPressed(0, 24) then
			if #self.data.Items > self.data.Pagination.total + 1 then
				if self:currentSelection() >= self.data.Pagination.max then
					if self:currentSelection() == #self.data.Items then
						self.data.Pagination.min = 0
						self.data.Pagination.max = self.data.Pagination.total + 1
						self.data.Index = 1000 - (1000 % #self.data.Items)
						self:UpdateSelection()
					else
						self.data.Pagination.max = self.data.Pagination.max + 1
						self.data.Pagination.min = self.data.Pagination.max - (self.data.Pagination.total + 1)
						self.data.Index = self.data.Index + 1
						self:UpdateSelection()
					end
				else
					self.data.Index = self.data.Index + 1
					self:UpdateSelection()
				end
			else
				self.data.Index = self.data.Index + 1
				self:UpdateSelection()
			end
		end
	end

	for Index = 1, #self.bar do
		if IsMouseInBounds(self.bar[Index].X + SafeZone.X, self.bar[Index].Y + SafeZone.Y, self.bar[Index].Width, self.bar[Index].height) then
			if IsDisabledControlJustPressed(0, 24) then
				self:currentSelection(self.data.Pagination.min + Index - 1)
			end
		end
	end
end

function MenuColorPanel:draw() -- required
    if self.data.enabled then
        self.background:Size(431 + self.parentItem:SetParentMenu().WidthOffset, 112)

        self.background:draw()
        self.leftArrow:draw()
        self.rightArrow:draw()
        self.text:draw()
        self.selectedRectangle:draw()
        for Index = 1, #self.bar do
            self.bar[Index]:draw()
        end
        self:Functions()
    end
end