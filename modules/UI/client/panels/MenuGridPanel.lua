MenuGridPanel = setmetatable({}, MenuGridPanel)
MenuGridPanel.__index = MenuGridPanel
MenuGridPanel.__call = function() return "MenuPanel", "MenuGridPanel" end

function MenuGridPanel.New(TopText, LeftText, RightText, BottomText)
	_MenuGridPanel = {
		Data = {
			Enabled = true,
		},
		Background = Sprite:new("commonmenu", "gradient_bgd", 0, 0, 431, 275),
		Grid = Sprite:new("pause_menu_pages_char_mom_dad", "nose_grid", 0, 0, 200, 200, 0),
		Circle = Sprite:new("mpinventory","in_world_circle", 0, 0, 20, 20, 0),
		Audio = {Slider = "CONTINUOUS_SLIDER", Library = "HUD_FRONTEND_DEFAULT_SOUNDSET", Id = nil},
		ParentItem = nil,
		Text = {
			Top = ResText:new(TopText or "Top", 0, 0, 0.35, 255, 255, 255, 255, 0, "Centre"),
			Left = ResText:new(LeftText or "Left", 0, 0, 0.35, 255, 255, 255, 255, 0, "Centre"),
			Right = ResText:new(RightText or "Right", 0, 0, 0.35, 255, 255, 255, 255, 0, "Centre"),
			Bottom = ResText:new(BottomText or "Bottom", 0, 0, 0.35, 255, 255, 255, 255, 0, "Centre"),
		},
	}
	return setmetatable(_MenuGridPanel, MenuGridPanel)
end

function MenuGridPanel:SetParentItem(Item) -- required
	if Item() == "MenuItem" then
		self.parentItem = Item
	else
		return self.parentItem
	end
end

function MenuGridPanel:enabled(Enabled)
	if type(Enabled) == "boolean" then
		self.data.enabled = Enabled
	else
		return self.data.enabled
	end
end

function MenuGridPanel:CirclePosition(X, Y)
    if tonumber(X) and tonumber(Y) then
        self.circle.X = (self.grid.X + 20) + ((self.grid.Width - 40) * ((X >= 0.0 and X <= 1.0) and X or 0.0)) - (self.circle.Width/2)
        self.circle.Y = (self.grid.Y + 20) + ((self.grid.height - 40) * ((Y >= 0.0 and Y <= 1.0) and Y or 0.0)) - (self.circle.height/2)
    else
        return math.round((self.circle.X - (self.grid.X + 20) + (self.circle.Width/2))/(self.grid.Width - 40), 2), math.round((self.circle.Y - (self.grid.Y + 20) + (self.circle.height/2))/(self.grid.height - 40), 2)
    end
end

function MenuGridPanel:position(Y) -- required
    if tonumber(Y) then
        local ParentOffsetX, ParentOffsetWidth = self.parentItem:Offset().X, self.parentItem:SetParentMenu().WidthOffset
        
        self.background:position(ParentOffsetX, Y)
        self.grid:position(ParentOffsetX + 115.5 + (ParentOffsetWidth/2), 37.5 + Y)
        self.text.Top:position(ParentOffsetX + 215.5 + (ParentOffsetWidth/2), 5 + Y)
        self.text.left:position(ParentOffsetX + 57.75 + (ParentOffsetWidth/2), 120 + Y)
        self.text.right:position(ParentOffsetX + 373.25 + (ParentOffsetWidth/2), 120 + Y)
        self.text.Bottom:position(ParentOffsetX + 215.5 + (ParentOffsetWidth/2), 240 + Y)

        if not self.circleLocked then
            self.circleLocked = true
            self:CirclePosition(0.5, 0.5)
        end
    end
end

function MenuGridPanel:UpdateParent(X, Y)
	local _, ParentType = self.parentItem()
    self.data.Value = {X = X, Y = Y}
	if ParentType == "MenuListItem" then
		local PanelItemIndex = self.parentItem:FindPanelItem()
		if PanelItemIndex then
			self.parentItem.Items[PanelItemIndex].Value[self.parentItem:FindPanelIndex(self)] = {X = X, Y = Y}
			self.parentItem:Index(PanelItemIndex)
			self.parentItem.Base.ParentMenu.OnListChange(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
			self.parentItem.OnListChanged(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
		else
			local PanelIndex = self.parentItem:FindPanelIndex(self)
			for Index = 1, #self.parentItem.Items do
				if type(self.parentItem.Items[Index]) == "table" then
					if not self.parentItem.Items[Index].panels then self.parentItem.Items[Index].panels = {} end
					self.parentItem.Items[Index].panels[PanelIndex] = {X = X, Y = Y}
				else
					self.parentItem.Items[Index] = {Name = tostring(self.parentItem.Items[Index]), Value = self.parentItem.Items[Index], Panels = {[PanelIndex] = {X = X, Y = Y}}}
				end
			end
			self.parentItem.Base.ParentMenu.OnListChange(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
			self.parentItem.OnListChanged(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)		
		end
    elseif ParentType == "MenuItem" then
        self.parentItem.ActivatedPanel(self.parentItem.ParentMenu, self.parentItem, self, {X = X, Y = Y})
	end
end

function MenuGridPanel:Functions()
    local SafeZone = {X = 0, Y = 0}
    if self.parentItem:SetParentMenu().Settings.ScaleWithSafezone then
       SafeZone = GetSafeZoneBounds()
    end

    if IsMouseInBounds(self.grid.X + 20 + SafeZone.X, self.grid.Y + 20 + SafeZone.Y, self.grid.Width - 40, self.grid.height - 40) then
        if IsDisabledControlJustPressed(0, 24) then
            if not self.pressed then
                self.pressed = true
                Citizen.CreateThread(function()
                    self.audio.Id = GetSoundId()
                    PlaySoundFrontend(self.audio.Id, self.audio.Slider, self.audio.Library, 1)
                    while IsDisabledControlPressed(0, 24) and IsMouseInBounds(self.grid.X + 20 + SafeZone.X, self.grid.Y + 20 + SafeZone.Y, self.grid.Width - 40, self.grid.height - 40) do
                        Citizen.Wait(0)
                        local CursorX, CursorY = math.round(GetControlNormal(0, 239) * 1920) - SafeZone.X - (self.circle.Width/2), math.round(GetControlNormal(0, 240) * 1080) - SafeZone.Y - (self.circle.height/2)

                        self.circle:position(((CursorX > (self.grid.X + 10 + self.grid.Width - 40)) and (self.grid.X + 10 + self.grid.Width - 40) or ((CursorX < (self.grid.X + 20 - (self.circle.Width/2))) and (self.grid.X + 20 - (self.circle.Width/2)) or CursorX)), ((CursorY > (self.grid.Y + 10 + self.grid.height - 40)) and (self.grid.Y + 10 + self.grid.height - 40) or ((CursorY < (self.grid.Y + 20 - (self.circle.height/2))) and (self.grid.Y + 20 - (self.circle.height/2)) or CursorY)))
                    end
                    StopSound(self.audio.Id)
                    ReleaseSoundId(self.audio.Id)
                    self.pressed = false
                end)
                Citizen.CreateThread(function()
                    while IsDisabledControlPressed(0, 24) and IsMouseInBounds(self.grid.X + 20 + SafeZone.X, self.grid.Y + 20 + SafeZone.Y, self.grid.Width - 40, self.grid.height - 40) do
                        Citizen.Wait(75)
                        local ResultX, ResultY = math.round((self.circle.X - (self.grid.X + 20) + (self.circle.Width/2))/(self.grid.Width - 40), 2), math.round((self.circle.Y - (self.grid.Y + 20) + (self.circle.height/2))/(self.grid.height - 40), 2)

                        self:UpdateParent((((ResultX >= 0.0 and ResultX <= 1.0) and ResultX or ((ResultX <= 0) and 0.0) or 1.0) * 2) - 1, (((ResultY >= 0.0 and ResultY <= 1.0) and ResultY or ((ResultY <= 0) and 0.0) or 1.0) * 2) - 1)
                    end
                end)
            end
        end
    end
end

function MenuGridPanel:draw() -- required
    if self.data.enabled then
        self.background:Size(431 + self.parentItem:SetParentMenu().WidthOffset, 275)

        self.background:draw()
        self.grid:draw()
        self.circle:draw()
        self.text.Top:draw()
        self.text.left:draw()
        self.text.right:draw()
        self.text.Bottom:draw()
        self:Functions()
    end
end