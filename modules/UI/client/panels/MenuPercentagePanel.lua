MenuPercentagePanel = setmetatable({}, MenuPercentagePanel)
MenuPercentagePanel.__index = MenuPercentagePanel
MenuPercentagePanel.__call = function() return "MenuPanel", "MenuPercentagePanel" end

function MenuPercentagePanel.New(MinText, MaxText)
	_MenuPercentagePanel = {
		Data = {
			Enabled = true,
		},
		Background = Sprite:new("commonmenu", "gradient_bgd", 0, 0, 431, 76),
		ActiveBar = ResRectangle:new(0, 0, 413, 10, 245, 245, 245, 255),
		BackgroundBar = ResRectangle:new(0, 0, 413, 10, 87, 87, 87, 255),
		Text = {
			Min = ResText:new(MinText or "0%", 0, 0, 0.35, 255, 255, 255, 255, 0, "Centre"),
			Max = ResText:new("100%", 0, 0, 0.35, 255, 255, 255, 255, 0, "Centre"),
			Title = ResText:new(MaxText or "Opacity", 0, 0, 0.35, 255, 255, 255, 255, 0, "Centre"),
		},
		Audio = {Slider = "CONTINUOUS_SLIDER", Library = "HUD_FRONTEND_DEFAULT_SOUNDSET", Id = nil},
		ParentItem = nil,
	}

	return setmetatable(_MenuPercentagePanel, MenuPercentagePanel)
end

function MenuPercentagePanel:SetParentItem(Item) -- required
	if Item() == "MenuItem" then
		self.parentItem = Item
	else
		return self.parentItem
	end
end

function MenuPercentagePanel:enabled(Enabled)
	if type(Enabled) == "boolean" then
		self.data.enabled = Enabled
	else
		return self.data.enabled
	end
end

function MenuPercentagePanel:position(Y) -- required
    if tonumber(Y) then
        local ParentOffsetX, ParentOffsetWidth = self.parentItem:Offset().X, self.parentItem:SetParentMenu().WidthOffset
        self.background:position(ParentOffsetX, Y)
        self.activeBar:position(ParentOffsetX + (ParentOffsetWidth/2) + 9, 50 + Y)
        self.backgroundBar:position(ParentOffsetX + (ParentOffsetWidth/2) + 9, 50 + Y)
        self.text.min:position(ParentOffsetX + (ParentOffsetWidth/2) + 25, 15 + Y)
        self.text.max:position(ParentOffsetX + (ParentOffsetWidth/2) + 398, 15 + Y)
        self.text.Title:position(ParentOffsetX + (ParentOffsetWidth/2) + 215.5, 15 + Y)
    end
end

function MenuPercentagePanel:Percentage(Value)
	if tonumber(Value) then
		local Percent = ((Value < 0.0) and 0.0) or ((Value > 1.0) and 1.0 or Value)
		self.activeBar:Size(self.backgroundBar.Width * Percent, self.activeBar.height)
	else
	    local SafeZone = {X = 0, Y = 0}
	    if self.parentItem:SetParentMenu().Settings.ScaleWithSafezone then
	       SafeZone = GetSafeZoneBounds()
	    end
	    
		local Progress = (math.round(GetControlNormal(0, 239) * 1920) - SafeZone.X) - self.activeBar.X
		return math.round(((Progress >= 0 and Progress <= 413) and Progress or ((Progress < 0) and 0 or 413))/self.backgroundBar.Width, 2)
	end
end

function MenuPercentagePanel:UpdateParent(Percentage)
	local _, ParentType = self.parentItem()
	if ParentType == "MenuListItem" then
		local PanelItemIndex = self.parentItem:FindPanelItem()
		if PanelItemIndex then
			self.parentItem.Items[PanelItemIndex].Value[self.parentItem:FindPanelIndex(self)] = Percentage
			self.parentItem:Index(PanelItemIndex)
			self.parentItem.Base.ParentMenu.OnListChange(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
			self.parentItem.OnListChanged(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
		else
			local PanelIndex = self.parentItem:FindPanelIndex(self)
			for Index = 1, #self.parentItem.Items do
				if type(self.parentItem.Items[Index]) == "table" then
					if not self.parentItem.Items[Index].panels then self.parentItem.Items[Index].panels = {} end
					self.parentItem.Items[Index].panels[PanelIndex] = Percentage
				else
					self.parentItem.Items[Index] = {Name = tostring(self.parentItem.Items[Index]), Value = self.parentItem.Items[Index], Panels = {[PanelIndex] = Percentage}}
				end
			end
			self.parentItem.Base.ParentMenu.OnListChange(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)
			self.parentItem.OnListChanged(self.parentItem.Base.ParentMenu, self.parentItem, self.parentItem._Index)		
		end
    elseif ParentType == "MenuItem" then
        self.parentItem.ActivatedPanel(self.parentItem.ParentMenu, self.parentItem, self, Percentage)
	end
end

function MenuPercentagePanel:Functions()

    local SafeZone = {X = 0, Y = 0}
    if self.parentItem:SetParentMenu().Settings.ScaleWithSafezone then
       SafeZone = GetSafeZoneBounds()
    end

    if IsMouseInBounds(self.backgroundBar.X + SafeZone.X, self.backgroundBar.Y - 4 + SafeZone.Y, self.backgroundBar.Width, self.backgroundBar.height + 8) then
        if IsDisabledControlJustPressed(0, 24) then
            if not self.pressed then
                self.pressed = true
                Citizen.CreateThread(function()
                    self.audio.Id = GetSoundId()
                    PlaySoundFrontend(self.audio.Id, self.audio.Slider, self.audio.Library, 1)
                    while IsDisabledControlPressed(0, 24) and IsMouseInBounds(self.backgroundBar.X + SafeZone.X, self.backgroundBar.Y - 4 + SafeZone.Y, self.backgroundBar.Width, self.backgroundBar.height + 8) do
                        Citizen.Wait(0)
                        local Progress = (math.round(GetControlNormal(0, 239) * 1920) - SafeZone.X) - self.activeBar.X
                        self.activeBar:Size(((Progress >= 0 and Progress <= 413) and Progress or ((Progress < 0) and 0 or 413)), self.activeBar.height)
                    end
                    StopSound(self.audio.Id)
                    ReleaseSoundId(self.audio.Id)
                    self.pressed = false
                end)
                Citizen.CreateThread(function()
                    while IsDisabledControlPressed(0, 24) and IsMouseInBounds(self.backgroundBar.X + SafeZone.X, self.backgroundBar.Y - 4 + SafeZone.Y, self.backgroundBar.Width, self.backgroundBar.height + 8) do
                        Citizen.Wait(75)
                        local Progress = (math.round(GetControlNormal(0, 239) * 1920) - SafeZone.X) - self.activeBar.X
                        self:UpdateParent(math.round(((Progress >= 0 and Progress <= 413) and Progress or ((Progress < 0) and 0 or 413))/self.backgroundBar.Width, 2))
                    end
                end)
            end
        end
    end
end

function MenuPercentagePanel:draw() -- required
    if self.data.enabled then
        self.background:Size(431 + self.parentItem:SetParentMenu().WidthOffset, 76)
        self.background:draw()
        self.backgroundBar:draw()
        self.activeBar:draw()
        self.text.min:draw()
        self.text.max:draw()
        self.text.Title:draw()
        self:Functions()
    end
end