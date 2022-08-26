local class = M("class");

function Menu:initialize(title, subtitle, x, y)
	self.logo = Sprite:new(TxtDictionary, TxtName, 0 + X, 0 + Y, 431, 107);
	self.banner = nil;
	self.title = ResText:new(title, 215 + X, 20 + Y, 1.15, 255, 255, 255, 255, 1, 1);
	self.subtitle = {
		extraY = 0
	};
	self.widthOffset = 0;
	self.position = {
		x = x, 
		y = y,
	};
	self.pagination = {
		min = 0, 
		max = 9, 
		total = 9
	};
	self.pageCounter = {
		preText = ""
	};
	self.extra = {};
	self.description = {};
	self.items = {};
	self.windows = {};
	self.children = {};
	self.controls = {
		Back = {
			Enabled = true,
		},
		Select = {
			Enabled = true,
		},
		Left = {
			Enabled = true,
		},
		Right = {
			Enabled = true,
		},
		Up = {
			Enabled = true,
		},
		Down = {
			Enabled = true,
		},
	};
	self.parentMenu = nil;
	self.parentItem = nil;
	self._visible = false;
	self.activeItem = 1000;
	self.dirty = false;
	self.reDraw = true;
	self.instructionalScaleform = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS");
	self.instructionalButtons = {};
	self.onIndexChange = function(menu, newindex) end;
	self.onListChange = function(menu, list, newindex) end;
	self.onSliderChange = function(menu, slider, newindex) end;
	self.onProgressChange = function(menu, progress, newindex) end;
	self.onCheckboxChange = function(menu, item, checked) end;
	self.onListSelect = function(menu, list, index) end;
	self.onSliderSelect = function(menu, slider, index) end;
	self.onProgressSelect = function(menu, progress, index) end;
	self.onItemSelect = function(menu, item, index) end;
	self.onMenuChanged = function(menu, newmenu, forward) end;
	self.onMenuClosed = function(menu) end;
	self.settings = {
		instructionalButtons = true,
		multilineFormats = true,
		scaleWithSafezone = true,
		ResetCursorOnOpen = true,
		MouseControlsEnabled = false,
		MouseEdgeEnabled = false,
		controlDisablingEnabled = true,
		audio = {
			library = "HUD_FRONTEND_DEFAULT_SOUNDSET",
			UpDown = "NAV_UP_DOWN",
			leftRight = "NAV_LEFT_RIGHT",
			Select = "SELECT",
			Back = "BACK",
			error = "ERROR",
		},
		EnabledControls = {
			Controller = {
				{0, 2}, -- Look Up and Down
				{0, 1}, -- Look Left and Right
				{0, 25}, -- Aim
				{0, 24}, -- Attack
			},
			Keyboard = {
				{0, 201}, -- Select
				{0, 195}, -- X axis
				{0, 196}, -- Y axis
				{0, 187}, -- Down
				{0, 188}, -- Up
				{0, 189}, -- Left
				{0, 190}, -- Right
				{0, 202}, -- Back
				{0, 217}, -- Select
				{0, 242}, -- Scroll down
				{0, 241}, -- Scroll up
				{0, 239}, -- Cursor X
				{0, 240}, -- Cursor Y
				{0, 31}, -- Move Up and Down
				{0, 30}, -- Move Left and Right
				{0, 21}, -- Sprint
				{0, 22}, -- Jump
				{0, 23}, -- Enter
				{0, 75}, -- Exit Vehicle
				{0, 71}, -- Accelerate Vehicle
				{0, 72}, -- Vehicle Brake
				{0, 59}, -- Move Vehicle Left and Right
				{0, 89}, -- Fly Yaw Left
				{0, 9}, -- Fly Left and Right
				{0, 8}, -- Fly Up and Down
				{0, 90}, -- Fly Yaw Right
				{0, 76}, -- Vehicle Handbrake
			},
		};
	}

	if subtitle then
		self.subtitle.rectangle = ResRectangle:new(self.position.x, self.position.y + 107, 431, 37, 0, 0, 0, 255);
		self.subtitle.text = ResText:new(subtitle, self.position.x + 8, self.position.y + 110, 0.35, 245, 245, 245, 255, 0);
		self.subtitle.backupText = subtitle
		self.subtitle.formatted = false;
		if string.starts(subtitle, "~") then
			self.pageCounter.preText = string.sub(subtitle, 1, 3);
		end
		self.pageCounter.text = ResText:new("", self.position.x + 425, self.position.y + 110, 0.35, 245, 245, 245, 255, 0, "Right");
		self.subtitle.extraY = 37;
	end
	
	self.arrowSprite = Sprite:new("commonmenu", "shop_arrows_upanddown", 190 + self.position.x, 147 + 37 * (self.pagination.total + 1) + self.position.y - 37 + self.subtitle.extraY, 50, 50)
	self.extra.up = ResRectangle:new(0 + self.position.x, 144 + 38 * (self.pagination.total + 1) + self.position.y - 37 + self.subtitle.extraY, 431, 18, 0, 0, 0, 200)
	self.extra.down = ResRectangle:new(0 + self.position.x, 144 + 18 + 38 * (self.pagination.total + 1) + self.position.y - 37 + self.subtitle.extraY, 431, 18, 0, 0, 0, 200)

	self.description.bar = ResRectangle:new(self.position.x, 123, 431, 4, 0, 0, 0, 255)
	self.description.rectangle = Sprite:new("commonmenu", "gradient_bgd", self.position.x, 127, 431, 30)
	self.description.text = ResText:new("Description", self.position.x + 5, 125, 0.35)

	self.background = Sprite:new("commonmenu", "gradient_bgd", self.position.x, 144 + self.position.y - 37 + self.subtitle.extraY, 290, 25)

	Citizen.CreateThread(function()
		if not HasScaleformMovieLoaded(self.instructionalScaleform) then
			self.instructionalScaleform = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
			while not HasScaleformMovieLoaded(self.instructionalScaleform) do
				Citizen.Wait(0);
			end
		end
	end)
end

function Menu:SetMenuWidthOffset(offset)
	self.widthOffset = math.floor(offset);
	self.logo:Size(431 + self.widthOffset, 107);
	self.title:position(((self.widthOffset + 431)/2) + self.position.x, 20 + self.position.y);
	if self.subtitle.rectangle ~= nil then
		self.subtitle.rectangle:Size(431 + self.widthOffset + 100, 37);
		self.pageCounter.text:position(425 + self.position.x + self.widthOffset, 110 + self.position.y);
	end
	if self.banner ~= nil then
		self.banner:Size(431 + self.widthOffset, 107);
	end
end

function Menu:disEnableControls(bool)
	if bool then
		EnableAllControlActions(2)
	else
		DisableAllControlActions(2)
	end

	if bool then
		return
	else
        if Controller() then
            for _,v in pairs(self.settings.enabledControls.Controller) do
                EnableControlAction(v[1], v[Index][2], true);
            end
        else
            for _,v in pairs(self.settings.enabledControls.Keyboard) do
                EnableControlAction(v[1], v[2], true);
            end
        end
    end
end

function Menu:InstructionalButtons(bool)
	self.settings.instructionalButtons = bool;
end

function Menu:SetBannerSprite(Sprite, includeChildren)
	self.logo = sprite;
	self.logo:Size(431 + self.widthOffset, 107);
	self.logo:position(self.position.x, self.position.y);
	self.banner = nil;
	if includeChildren then
		for Item, Menu in pairs(self.children) do
			Menu.Logo = Sprite
			Menu.Logo:Size(431 + self.widthOffset, 107)
			Menu.Logo:position(self.position.x, self.position.y)
			Menu.Banner = nil
		end
	end
end

function Menu:SetBannerRectangle(rectangle, includeChildren)
    if rectangle() == "Rectangle" then
        self.banner = rectangle
        self.banner:Size(431 + self.widthOffset, 107)
        self.banner:position(self.position.x, self.position.y)
        self.logo = nil
        if includeChildren then
            for Item, Menu in pairs(self.children) do
                Menu.Banner = rectangle
                Menu.Banner:Size(431 + self.widthOffset, 107)
                Menu:position(self.position.x, self.position.y)
                Menu.Logo = nil
            end
        end
    end
end

function Menu:currentSelection(value)
	if tonumber(value) then
		if #self.items == 0 then
			self.activeItem = 0
		end

		self.items[self:currentSelection()]:selected(false)
		self.activeItem = 1000000 - (1000000 % #self.items) + tonumber(value)

		if self:currentSelection() > self.pagination.max then
			self.pagination.min = self:currentSelection() - self.pagination.total
			self.pagination.max = self:currentSelection()
		elseif self:currentSelection() < self.pagination.min then
			self.pagination.min = self:currentSelection()
			self.pagination.max = self:currentSelection() + self.pagination.total
		end 
	else
		if #self.items == 0 then
			return 1
		else
			if self.activeItem % #self.items == 0 then
				return 1
			else
				return self.activeItem % #self.items + 1
			end
		end
	end
end

function Menu:CalculateWindowHeight()
	local height = 0
	for i = 1, #self.windows do
		height = height + self.windows[i].Background:Size().height
	end
	return height
end

function Menu:CalculateItemHeightOffset(Item)
	if Item.Base then
		return Item.Base.rectangle.height
	else
		return Item.rectangle.height
	end
end

function Menu:CalculateItemHeight()
	local itemOffset = 0 + self.subtitle.extraY - 37;
	for i = self.pagination.min + 1, self.pagination.max do
		local item = self.items[i]
		if item ~= nil then
			itemOffset = itemOffset + self:CalculateItemHeightOffset(item)
		end
	end
	return itemOffset
end

function Menu:RecalculateDescriptionPosition()
	local windowHeight = self:CalculateWindowHeight()
    self.description.bar:position(self.position.x, 149 + self.position.y + WindowHeight)
    self.description.rectangle:position(self.position.x, 149 + self.position.y + WindowHeight)
    self.description.text:position(self.position.x + 8, 155 + self.position.y + WindowHeight)

	self.description.bar:Size(431 + self.widthOffset, 4)
	self.description.rectangle:Size(431 + self.widthOffset, 30)

	self.description.bar:position(self.position.x, self:CalculateItemHeight() + ((#self.items > (self.pagination.total + 1)) and 37 or 0) + self.description.bar:position().Y)
	self.description.rectangle:position(self.position.x, self:CalculateItemHeight() + ((#self.items > (self.pagination.total + 1)) and 37 or 0) + self.description.rectangle:position().Y)
	self.description.text:position(self.position.x + 8, self:CalculateItemHeight() + ((#self.items > (self.pagination.total + 1)) and 37 or 0) + self.description.text:position().Y)
end

function Menu:CaclulatePanelPosition(HasDescription)
	local height = self:CalculateWindowHeight() + 149 + self.position.y

	if HasDescription then
		height = height + self.description.rectangle:Size().height + 5
	end

	return self:CalculateItemHeight() + ((#self.items > (self.pagination.total + 1)) and 37 or 0) + height
end

function Menu:AddWindow(window)
	window:SetParentMenu(self)
	window:Offset(self.position.x, self.position.y)
	table.insert(self.windows, window)
	self.reDraw = true
	self:RecalculateDescriptionPosition()
end

function Menu:RemoveWindowAt(index)
	if self.windows[index] then
		table.remove(self.windows, index);
		self.reDraw = true;
		self:RecalculateDescriptionPosition();
	end
end

function Menu:AddItem(item)
	if item() == "MenuItem" then
		local selectedItem = self:currentSelection()
		item:SetParentMenu(self)
		item:Offset(self.position.x, self.position.y)
		item:position((#self.items * 25) - 37 + self.subtitle.extraY)
		table.insert(self.items, item)
		self:RecalculateDescriptionPosition()
		self:currentSelection(selectedItem)
	end
end

function Menu:RemoveItemAt(index)
	if self.items[index] then
		local SelectedItem = self:currentSelection()
		if #self.items > self.pagination.total and self.pagination.max == #self.items - 1 then
			self.pagination.min = self.pagination.min - 1;
			self.pagination.max = self.pagination.max + 1;
		end
		table.remove(self.items, index)
		self:RecalculateDescriptionPosition()
		self:currentSelection(SelectedItem)
	end
end

function Menu:RefreshIndex()
	if #self.items == 0 then
		self.activeItem = 1000
		self.pagination.max = self.pagination.total + 1
		self.pagination.min = 0
		return
	end
	self.items[self:currentSelection()]:selected(false)
	self.activeItem = 1000 - (1000 % #self.items)
	self.pagination.max = self.pagination.total + 1
	self.pagination.min = 0
	self.reDraw = true
end

function Menu:Clear()
	self.items = {}
    self.reDraw = true
	self:RecalculateDescriptionPosition()
end

function Menu:MultilineFormat(str)
	local pixelsPerLine = 425 + self.widthOffset;
	local aggregatePixels = 0
	local output = ""
	local words = string.split(tostring(str), " ")

	for i = 1, #words do
		local offset = MeasureStringWidth(words[i], 0, 0.35)
		aggregatePixels = aggregatePixels + offset
		if aggregatePixels > pixelsPerLine then
			output = output .. "\n" .. words[i] .. " "
			aggregatePixels = offset + MeasureString(" ")
		else
			output = output .. words[i] .. " "
			aggregatePixels = aggregatePixels + MeasureString(" ")
		end
	end
	return output;
end

function Menu:drawCalculations()
	local windowHeight = self:CalculateWindowHeight()

	if self.settings.multilineFormats then
		if self.subtitle.rectangle and not self.subtitle.formatted then
			self.subtitle.formatted = true
			self.subtitle.text:Text(self:MultilineFormat(self.subtitle.text:Text()))

			local Linecount = #string.split(self.subtitle.text:Text(), "\n")
			self.subtitle.extraY = ((Linecount == 1) and 37 or ((Linecount + 1) * 22))
			self.subtitle.rectangle:Size(431 + self.widthOffset, self.subtitle.extraY)
		end
	elseif self.subtitle.formatted then
		self.subtitle.formatted = false
		self.subtitle.extraY = 37
		self.subtitle.rectangle:Size(431 + self.widthOffset, self.subtitle.extraY)
		self.subtitle.text:Text(self.subtitle.BackupText)
	end

    self.background:Size(431 + self.widthOffset, self:CalculateItemHeight() + WindowHeight + ((self.subtitle.extraY > 0) and 0 or 37))

	self.extra.up:Size(431 + self.widthOffset, 18)
	self.extra.down:Size(431 + self.widthOffset, 18)

    self.extra.up:position(self.position.x, 144 + self:CalculateItemHeight() + self.position.y + WindowHeight)
    self.extra.down:position(self.position.x, 144 + 18 + self:CalculateItemHeight() + self.position.y + WindowHeight)

    if self.widthOffset > 0 then
        self.arrowSprite:position(190 + self.position.x + (self.widthOffset / 2), 137 + self:CalculateItemHeight() + self.position.y + WindowHeight)
    else
        self.arrowSprite:position(190 + self.position.x + self.widthOffset, 137 + self:CalculateItemHeight() + self.position.y + WindowHeight)
    end

	self.reDraw = false

	if #self.items ~= 0 and self.items[self:currentSelection()]:description() ~= "" then
		self:RecalculateDescriptionPosition()

		local description = self.items[self:currentSelection()]:description()
		if self.settings.multilineFormats then
			self.description.text:Text(self:MultilineFormat(description))
		else
			self.description.text:Text(description)
		end

		local Linecount = #string.split(self.description.text:Text(), "\n")
		self.description.rectangle:Size(431 + self.widthOffset, ((Linecount == 1) and 37 or ((Linecount + 1) * 22)))
	end
end

function Menu:visible(bool)
	if bool ~= nil then
		self._visible = tobool(bool)
		self.justOpened = tobool(bool)
		self.dirty = tobool(bool)
		self:updateScaleform()
		if self.parentMenu ~= nil or tobool(bool) == false then
			return
		end
		if self.settings.ResetCursorOnOpen then
			local w, h = GetScreenResolution()
			SetCursorLocation(W / 2, H / 2)
			SetCursorSprite(1)
		end
	else
		return self._visible
	end
end

function Menu:ProcessControl()
	if not self._visible then
		return
	end

	if self.justOpened then
		self.justOpened = false
		return
	end

	if self.controls.Back.enabled and (IsDisabledControlJustReleased(0, 177) or IsDisabledControlJustReleased(1, 177) or IsDisabledControlJustReleased(2, 177) or IsDisabledControlJustReleased(0, 199) or IsDisabledControlJustReleased(1, 199) or IsDisabledControlJustReleased(2, 199)) then
		self:GoBack()
	end
	
	if #self.items == 0 then
		return
	end

	if not self.upPressed then
		if self.controls.up.enabled and (IsDisabledControlJustPressed(0, 172) or IsDisabledControlJustPressed(1, 172) or IsDisabledControlJustPressed(2, 172) or IsDisabledControlJustPressed(0, 241) or IsDisabledControlJustPressed(1, 241) or IsDisabledControlJustPressed(2, 241) or IsDisabledControlJustPressed(2, 241)) then
			Citizen.CreateThread(function()
				self.upPressed = true
				if #self.items > self.pagination.total + 1 then
					self:goUpOverflow()
				else
					self:goUp()
				end
				self:updateScaleform()
				Citizen.Wait(175)
				while self.controls.up.enabled and (IsDisabledControlPressed(0, 172) or IsDisabledControlPressed(1, 172) or IsDisabledControlPressed(2, 172) or IsDisabledControlPressed(0, 241) or IsDisabledControlPressed(1, 241) or IsDisabledControlPressed(2, 241) or IsDisabledControlPressed(2, 241)) do
					if #self.items > self.pagination.total + 1 then
						self:goUpOverflow()
					else
						self:goUp()
					end
					self:updateScaleform()
					Citizen.Wait(125)
				end
				self.upPressed = false
			end)
		end
	end

	if not self.downPressed then
		if self.controls.down.enabled and (IsDisabledControlJustPressed(0, 173) or IsDisabledControlJustPressed(1, 173) or IsDisabledControlJustPressed(2, 173) or IsDisabledControlJustPressed(0, 242) or IsDisabledControlJustPressed(1, 242) or IsDisabledControlJustPressed(2, 242)) then
			Citizen.CreateThread(function()
				self.downPressed = true
				if #self.items > self.pagination.total + 1 then
					self:goDownOverflow()
				else
					self:goDown()
				end
				self:updateScaleform()
				Citizen.Wait(175)
				while self.controls.down.enabled and (IsDisabledControlPressed(0, 173) or IsDisabledControlPressed(1, 173) or IsDisabledControlPressed(2, 173) or IsDisabledControlPressed(0, 242) or IsDisabledControlPressed(1, 242) or IsDisabledControlPressed(2, 242)) do
					if #self.items > self.pagination.total + 1 then
						self:goDownOverflow()
					else
						self:goDown()
					end
					self:updateScaleform()
					Citizen.Wait(125)
				end
				self.downPressed = false;
			end)
		end
	end

	if not self.leftPressed then
		if self.controls.left.enabled and (IsDisabledControlPressed(0, 174) or IsDisabledControlPressed(1, 174) or IsDisabledControlPressed(2, 174)) then
			Citizen.CreateThread(function()
				self.leftPressed = true
				self:goLeft()
				Citizen.Wait(175)
				while self.controls.left.enabled and (IsDisabledControlPressed(0, 174) or IsDisabledControlPressed(1, 174) or IsDisabledControlPressed(2, 174)) do
					self:goLeft()
					Citizen.Wait(125)
				end
				self.leftPressed = false
			end)
		end
	end

	if not self.rightPressed then
		if self.controls.right.enabled and (IsDisabledControlPressed(0, 175) or IsDisabledControlPressed(1, 175) or IsDisabledControlPressed(2, 175)) then
			Citizen.CreateThread(function()
				self.rightPressed = true
				self:goRight()
				Citizen.Wait(175)
				while self.controls.right.enabled and (IsDisabledControlPressed(0, 175) or IsDisabledControlPressed(1, 175) or IsDisabledControlPressed(2, 175)) do
					self:goRight()
					Citizen.Wait(125)
				end
				self.rightPressed = false
			end)
		end
	end

	if self.controls.Select.enabled and (IsDisabledControlJustPressed(0, 201) or IsDisabledControlJustPressed(1, 201) or IsDisabledControlJustPressed(2, 201)) then
		self:selectItem()
	end
end

function Menu:goUpOverflow()
	if #self.items <= self.pagination.total + 1 then
		return
	end

	if self:currentSelection() <= self.pagination.min + 1 then
		if self:currentSelection() == 1 then
			self.pagination.min = #self.items - (self.pagination.total + 1)
			self.pagination.max = #self.items
			self.items[self:currentSelection()]:selected(false)
			self.activeItem = 1000 - (1000 % #self.items)
			self.activeItem = self.activeItem + (#self.items - 1)
			self.items[self:currentSelection()]:selected(true)
		else
			self.pagination.min = self.pagination.min - 1
			self.pagination.max = self.pagination.max - 1
			self.items[self:currentSelection()]:selected(false)
			self.activeItem = self.activeItem - 1
			self.items[self:currentSelection()]:selected(true)
		end
	else
		self.items[self:currentSelection()]:selected(false)
		self.activeItem = self.activeItem - 1
		self.items[self:currentSelection()]:selected(true)
	end
	PlaySoundFrontend(-1, self.settings.audio.upDown, self.settings.audio.library, true)
	self.onIndexChange(self, self:currentSelection())
	self.reDraw = true
end

function Menu:goUp()
	if #self.items > self.pagination.total + 1 then
		return
	end
	self.items[self:currentSelection()]:selected(false)
	self.activeItem = self.activeItem - 1
	self.items[self:currentSelection()]:selected(true)
	PlaySoundFrontend(-1, self.settings.audio.upDown, self.settings.audio.library, true)
	self.onIndexChange(self, self:currentSelection())
	self.reDraw = true
end

function Menu:goDownOverflow()
	if #self.items <= self.pagination.total + 1 then
		return
	end

	if self:currentSelection() >= self.pagination.max then
		if self:currentSelection() == #self.items then
			self.pagination.min = 0
			self.pagination.max = self.pagination.total + 1
			self.items[self:currentSelection()]:selected(false)
			self.activeItem = 1000 - (1000 % #self.items)
			self.items[self:currentSelection()]:selected(true)
		else
			self.pagination.max = self.pagination.max + 1
			self.pagination.min = self.pagination.max - (self.pagination.total + 1)
			self.items[self:currentSelection()]:selected(false)
			self.activeItem = self.activeItem + 1
			self.items[self:currentSelection()]:selected(true)            
		end
	else
		self.items[self:currentSelection()]:selected(false)
		self.activeItem = self.activeItem + 1
		self.items[self:currentSelection()]:selected(true)
	end
	PlaySoundFrontend(-1, self.settings.audio.upDown, self.settings.audio.library, true)
	self.onIndexChange(self, self:currentSelection())
	self.reDraw = true
end

function Menu:goDown()
	if #self.items > self.pagination.total + 1 then
		return
	end

	self.items[self:currentSelection()]:selected(false)
	self.activeItem = self.activeItem + 1
	self.items[self:currentSelection()]:selected(true) 
	PlaySoundFrontend(-1, self.settings.audio.upDown, self.settings.audio.library, true)
	self.onIndexChange(self, self:currentSelection())
	self.reDraw = true
end

function Menu:goLeft()
	local itemClass = self.items[self:currentSelection()].class;

	if itemClass ~= MenuListItem
		and itemClass ~= MenuSliderItem
		and subtype ~= MenuProgressItem then
		return
	end

	if not self.items[self:currentSelection()]:enabled() then
		PlaySoundFrontend(-1, self.settings.audio.error, self.settings.audio.library, true)
		return
	end
	
	if itemClass == MenuListItem then
		local item = self.items[self:currentSelection()]
		item:index(item._index - 1)
		self.onListChange(self, item, item._index)
		item.OnListChanged(self, item, item._index)
		PlaySoundFrontend(-1, self.settings.audio.leftRight, self.settings.audio.library, true)
	elseif itemClass == MenuSliderItem then
		local item = self.items[self:currentSelection()]
		item:Index(item._Index - 1)
		self.onSliderChange(self, item, item:Index())
		item.OnSliderChanged(self, item, item._Index)
		PlaySoundFrontend(-1, self.settings.audio.leftRight, self.settings.audio.library, true)
	elseif itemClass == MenuProgressItem then
		local item = self.items[self:currentSelection()]
		item:Index(item.Data.Index - 1)
		self.onProgressChange(self, item, item.Data.Index)
		item.onProgressChanged(self, item, item.Data.Index)
		PlaySoundFrontend(-1, self.settings.audio.leftRight, self.settings.audio.library, true)
	end
end

function Menu:goRight()
	local itemClass = self.items[self:currentSelection()].class;

	if itemClass ~= MenuListItem 
		and itemClass ~= MenuSliderItem 
		and itemClass ~= MenuProgressItem then
		return
	end

	if not self.items[self:currentSelection()]:enabled() then
		PlaySoundFrontend(-1, self.settings.audio.error, self.settings.audio.library, true)
		return
	end

	if itemClass == MenuListItem then
		local Item = self.items[self:currentSelection()]
		Item:Index(Item._Index + 1)
		self.onListChange(self, Item, Item._Index)
		Item.OnListChanged(self, Item, Item._Index)
		PlaySoundFrontend(-1, self.settings.audio.leftRight, self.settings.audio.library, true)
	elseif itemClass == MenuSliderItem then
		local item = self.items[self:currentSelection()]
		item:Index(item._Index + 1)
		self.onSliderChange(self, item, item:Index())
		item.OnSliderChanged(self, item, item._Index)
		PlaySoundFrontend(-1, self.settings.audio.leftRight, self.settings.audio.library, true)
	elseif itemClass == MenuProgressItem then
		local item = self.items[self:currentSelection()]
		item:index(item.Data.Index + 1)
		self.onProgressChange(self, item, item.Data.Index)
		item.onProgressChanged(self, item, item.Data.Index)
		PlaySoundFrontend(-1, self.settings.audio.leftRight, self.settings.audio.library, true)
	end
end

function Menu:selectItem()
	if not self.items[self:currentSelection()]:enabled() then
		PlaySoundFrontend(-1, self.settings.audio.error, self.settings.audio.library, true)
		return
	end
	local item = self.items[self:currentSelection()]
	local itemClass = item.class;
	if itemClass == MenuCheckboxItem then
		item.checked = not item.checked
		PlaySoundFrontend(-1, self.settings.audio.Select, self.settings.audio.library, true)
		self.onCheckboxChange(self, item, item.checked)
		item.CheckboxEvent(self, item, item.checked)
	elseif itemClass == MenuListItem then
		PlaySoundFrontend(-1, self.settings.audio.Select, self.settings.audio.library, true)
		self.onListSelect(self, item, item._Index)
		item.OnListSelected(self, item, item._Index)
	elseif itemClass == MenuSliderItem then
		PlaySoundFrontend(-1, self.settings.audio.Select, self.settings.audio.library, true)
		self.onSliderSelect(self, item, item._Index)
		item.OnSliderSelected(item._Index)
	elseif itemClass == MenuProgressItem then
		PlaySoundFrontend(-1, self.settings.audio.Select, self.settings.audio.library, true)
		self.onProgressSelect(self, item, item.Data.Index)
		item.OnProgressSelected(item.Data.Index)		
	else
		PlaySoundFrontend(-1, self.settings.audio.Select, self.settings.audio.library, true)
		self.onItemSelect(self, item, self:currentSelection())
		item.Activated(self, item)
		if not self.children[item] then
			return
		end
		self:visible(false)
		self.children[item]:visible(true)
		self.onMenuChanged(self, self.children[self.items[self:currentSelection()]], true)
	end
end

function Menu:GoBack()
	PlaySoundFrontend(-1, self.settings.audio.Back, self.settings.audio.library, true)
	self:visible(false)
	if self.parentMenu ~= nil then
		self.parentMenu:visible(true)
		self.onMenuChanged(self, self.parentMenu, false)
		if self.settings.ResetCursorOnOpen then
			local w, h = GetActiveScreenResolution()
			SetCursorLocation(W / 2, H / 2)
		end
	end
	self.onMenuClosed(self)
end

function Menu:bindMenuToItem(menu, item)
	if menu.class == Menu and item.class == MenuItem then
		menu.parentMenu = self;
		menu.parentItem = item;
		self.children[item] = menu;
	end
end

function Menu:releaseMenuFromItem(item)
	if item.class == MenuItem then
		if not self.children[item] then
			return false
		end
		self.children[item].parentMenu = nil;
		self.children[item].parentItem = nil;
		self.children[item] = nil;
		return true;
	end
end

function Menu:draw()
	if not self._visible then
		return;
	end

	HideHudComponentThisFrame(19)

	if self.settings.controlDisablingEnabled then
		self:disEnableControls(false)
	end

	if self.settings.instructionalButtons then
		DrawScaleformMovieFullscreen(self.instructionalScaleform, 255, 255, 255, 255, 0)
	end

	if self.settings.scaleWithSafezone then
		ScreenDrawPositionBegin(76, 84)
		ScreenDrawPositionRatio(0, 0, 0, 0)
	end

	if self.reDraw then
		self:drawCalculations()
	end

	if self.logo then
		self.logo:draw()
	elseif self.banner then
		self.banner:draw()
	end

	self.title:draw()

	if self.subtitle.rectangle then
		self.subtitle.rectangle:draw()
		self.subtitle.text:draw()
	end

	if #self.items ~= 0 or #self.windows ~= 0 then
		self.background:draw()
	end

	if #self.windows ~= 0 then
		local windowOffset = 0
		for index = 1, #self.windows do
			if self.windows[index - 1] then 
				windowOffset = windowOffset + self.windows[index - 1].Background:Size().height 
			end
			local window = self.windows[index]
			Window:position(windowOffset + self.subtitle.extraY - 37)
			Window:draw()
		end
	end

	if #self.items == 0 then
		if self.settings.scaleWithSafezone then
			ScreenDrawPositionEnd()
		end
		return;
	end

	local currentSelection = self:currentSelection()
	self.items[currentSelection]:selected(true)

	if self.items[currentSelection]:description() ~= "" then
		self.description.bar:draw()
		self.description.rectangle:draw()
		self.description.text:draw()
	end

	if self.items[currentSelection].panels ~= nil then
		if #self.items[currentSelection].panels ~= 0 then
			local panelOffset = self:CaclulatePanelPosition(self.items[currentSelection]:description() ~= "")
			for index = 1, #self.items[currentSelection].panels do
				if self.items[currentSelection].panels[index - 1] then 
					panelOffset = panelOffset + self.items[currentSelection].panels[index - 1].background:Size().height + 5
				end
				self.items[currentSelection].panels[index]:position(panelOffset)
				self.items[currentSelection].panels[index]:draw()
			end
		end
	end

	local windowHeight = self:CalculateWindowHeight()

	if #self.items <= self.pagination.total + 1 then
		local ItemOffset = self.subtitle.extraY - 37 + WindowHeight
		for index = 1, #self.items do
			Item = self.items[index]
			Item:position(ItemOffset)
			Item:draw()
			ItemOffset = ItemOffset + self:CalculateItemHeightOffset(Item)
		end
	else
		local itemOffset = self.subtitle.extraY - 37 + WindowHeight
		for index = self.pagination.min + 1, self.pagination.max, 1 do
			if self.items[index] then
				Item = self.items[index]
				Item:position(itemOffset)
				Item:draw()
				itemOffset = itemOffset + self:CalculateItemHeightOffset(Item)
			end
		end

		self.extra.up:draw()
		self.extra.down:draw()
		self.arrowSprite:draw()

		if self.pageCounter.text ~= nil then
			local Caption = self.pageCounter.PreText .. currentSelection .. " / " .. #self.items
			self.pageCounter.text:Text(Caption)
			self.pageCounter.text:draw()
		end
	end

	if self.settings.scaleWithSafezone then
		ScreenDrawPositionEnd()
	end
end

function Menu:processMouse()
	if not self._visible or self.justOpened or #self.items == 0 or tobool(Controller()) or not self.settings.MouseControlsEnabled then
		EnableControlAction(0, 2, true)
		EnableControlAction(0, 1, true)
		EnableControlAction(0, 25, true)
		EnableControlAction(0, 24, true)
		if self.dirty then
			for _, item in pairs(self.items) do
				if item:hovered() then
					item:hovered(false)
				end
			end
		end
		return
	end

    local safeZone = {X = 0, Y = 0}
    local windowHeight = self:CalculateWindowHeight()
    if self.settings.scaleWithSafezone then
	   safeZone = GetSafeZoneBounds()
    end

	local Limit = #self.items
	local itemOffset = 0

	ShowCursorThisFrame()

	if #self.items > self.pagination.total + 1 then
		Limit = self.pagination.max
	end

	if IsMouseInBounds(0, 0, 30, 1080) and self.settings.MouseEdgeEnabled then
		SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading() + 5)
		SetCursorSprite(6)
	elseif IsMouseInBounds(1920 - 30, 0, 30, 1080) and self.settings.MouseEdgeEnabled then
		SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading() - 5)
		SetCursorSprite(7)	
	elseif self.settings.MouseEdgeEnabled then
		SetCursorSprite(1)
	end

	for i = self.pagination.min + 1, Limit, 1 do
		local X, Y = self.position.x + safeZone.X, self.position.y + 144 - 37 + self.subtitle.extraY + itemOffset + safeZone.Y + WindowHeight
		local item = self.items[i]
		local itemClass = item.class;
		local width, height = 431 + self.widthOffset, self:CalculateItemHeightOffset(item)

		if IsMouseInBounds(X, Y, Width, height) then
			item:hovered(true)
			if not self.controls.mousePressed then
				if IsDisabledControlJustPressed(0, 24) then
					Citizen.CreateThread(function()
						local _x, _y, _width, _height = X, Y, Width, height
						self.controls.mousePressed = true
						if item:selected() and item:enabled() then
							if itemClass == MenuListItem then
								if IsMouseInBounds(item.leftArrow.X + safeZone.X, item.leftArrow.Y + safeZone.Y, item.leftArrow.Width, item.leftArrow.height) then
									self:goLeft()
								elseif not IsMouseInBounds(item.rightArrow.X + safeZone.X, item.rightArrow.Y + safeZone.Y, item.rightArrow.Width, item.rightArrow.height) then
									self:selectItem()
								end
								if IsMouseInBounds(item.rightArrow.X + safeZone.X, item.rightArrow.Y + safeZone.Y, item.rightArrow.Width, item.rightArrow.height) then
									self:goRight()
								elseif not IsMouseInBounds(item.leftArrow.X + safeZone.X, item.leftArrow.Y + safeZone.Y, item.leftArrow.Width, item.leftArrow.height) then
									self:selectItem()
								end
							elseif itemClass == MenuSliderItem then
								if IsMouseInBounds(item.leftArrow.X + safeZone.X, item.leftArrow.Y + safeZone.Y, item.leftArrow.Width, item.leftArrow.height) then
									self:goLeft()
								elseif not IsMouseInBounds(item.rightArrow.X + safeZone.X, item.rightArrow.Y + safeZone.Y, item.rightArrow.Width, item.rightArrow.height) then
									self:selectItem()
								end
								if IsMouseInBounds(item.rightArrow.X + safeZone.X, item.rightArrow.Y + safeZone.Y, item.rightArrow.Width, item.rightArrow.height) then
									self:goRight()
								elseif not IsMouseInBounds(item.leftArrow.X + safeZone.X, item.leftArrow.Y + safeZone.Y, item.leftArrow.Width, item.leftArrow.height) then
									self:selectItem()
								end
							elseif itemClass == MenuProgressItem then
								if IsMouseInBounds(item.bar.X + safeZone.X, item.bar.Y + safeZone.Y - 12, item.data.max, item.bar.height + 24) then
									item:CalculateProgress(math.round(GetControlNormal(0, 239) * 1920) - safeZone.X)
                                    self.onProgressChange(self, item, item.data.index);
                                    item.onProgressChanged(self, item, item.data.index);
								else
									self:selectItem()
								end
							else
								self:selectItem()
							end
						elseif not item:selected() then
							self:currentSelection(i-1)
							PlaySoundFrontend(-1, self.settings.audio.error, self.settings.audio.library, true)
							self.onIndexChange(self, self:currentSelection())
							self.reDraw = true
							self:updateScaleform()
						elseif not item:enabled() and item:selected() then
							PlaySoundFrontend(-1, self.settings.audio.error, self.settings.audio.library, true)
						end
						Citizen.Wait(175)
						while IsDisabledControlPressed(0, 24) and IsMouseInBounds(_x, _y, _width, _height) do
							if item:selected() and item:enabled() then
								if itemClass == MenuListItem then
									if IsMouseInBounds(item.leftArrow.X + safeZone.X, item.leftArrow.Y + safeZone.Y, item.leftArrow.Width, item.leftArrow.height) then
										self:goLeft()
									end
									if IsMouseInBounds(item.rightArrow.X + safeZone.X, item.rightArrow.Y + safeZone.Y, item.rightArrow.Width, item.rightArrow.height) then
										self:goRight()
									end
								elseif itemClass == MenuSliderItem then
									if IsMouseInBounds(item.leftArrow.X + safeZone.X, item.leftArrow.Y + safeZone.Y, item.leftArrow.Width, item.leftArrow.height) then
										self:goLeft()
									end
									if IsMouseInBounds(item.rightArrow.X + safeZone.X, item.rightArrow.Y + safeZone.Y, item.rightArrow.Width, item.rightArrow.height) then
										self:goRight()
									end
								elseif itemClass == MenuProgressItem then
									if IsMouseInBounds(item.bar.X + safeZone.X, item.bar.Y + safeZone.Y - 12, item.data.max, item.bar.height + 24) then
										item:CalculateProgress(math.round(GetControlNormal(0, 239) * 1920) - safeZone.X)
                                        self.onProgressChange(self, item, item.data.index)
                                        item.onProgressChanged(self, item, item.data.index)
									else
										self:selectItem()
									end
								end
							elseif not item:selected() then
								self:currentSelection(i-1)
								PlaySoundFrontend(-1, self.settings.audio.error, self.settings.audio.library, true)
								self.onIndexChange(self, self:currentSelection())
								self.reDraw = true
								self:updateScaleform()
							elseif not item:enabled() and item:selected() then
								PlaySoundFrontend(-1, self.settings.audio.error, self.settings.audio.library, true)
							end
							Citizen.Wait(125)						
						end
						self.controls.mousePressed = false
					end)
				end
			end
		else
			item:hovered(false)
		end
		itemOffset = itemOffset + self:CalculateItemHeightOffset(item)
	end

	local extraX, extraY = self.position.x + safeZone.X, 144 + self:CalculateItemHeight() + self.position.y + safeZone.Y + WindowHeight

	if #self.items <= self.pagination.total + 1 then return end

	if IsMouseInBounds(extraX, extraY, 431 + self.widthOffset, 18) then
		self.extra.up:color(30, 30, 30, 255)
		if not self.controls.mousePressed then
			if IsDisabledControlJustPressed(0, 24) then
				Citizen.CreateThread(function()
					local _extraX, _extraY = extraX, extraY
					self.controls.mousePressed = true
					if #self.items > self.pagination.total + 1 then
						self:goUpOverflow()
					else
						self:goUp()
					end
					Citizen.Wait(175)
					while IsDisabledControlPressed(0, 24) and IsMouseInBounds(_extraX, _extraY, 431 + self.widthOffset, 18) do
						if #self.items > self.pagination.total + 1 then
							self:goUpOverflow()
						else
							self:goUp()
						end
						Citizen.Wait(125)
					end
					self.controls.mousePressed = false;			
				end)
			end
		end
	else
		self.extra.up:color(0, 0, 0, 200)
	end

	if IsMouseInBounds(extraX, extraY + 18, 431 + self.widthOffset, 18) then
		self.extra.down:color(30, 30, 30, 255)
		if not self.controls.mousePressed then
			if IsDisabledControlJustPressed(0, 24) then
				Citizen.CreateThread(function()
					local _extraX, _extraY = extraX, extraY
					self.controls.mousePressed = true
					if #self.items > self.pagination.total + 1 then
						self:goDownOverflow()
					else
						self:goDown()
					end
					Citizen.Wait(175)
					while IsDisabledControlPressed(0, 24) and IsMouseInBounds(_extraX, _extraY + 18, 431 + self.widthOffset, 18) do
						if #self.items > self.pagination.total + 1 then
							self:goDownOverflow()
						else
							self:goDown()
						end
						Citizen.Wait(125)
					end
					self.controls.mousePressed = false			
				end)
			end
		end
	else
		self.extra.down:color(0, 0, 0, 200)
	end
end

function Menu:AddInstructionButton(button)
	if type(button) == "table" and #button == 2 then
		table.insert(self.instructionalButtons, button)
	end
end

function Menu:RemoveInstructionButton(button)
	if type(button) == "table" then
		for i = 1, #self.instructionalButtons do
			if button == self.instructionalButtons[i] then
				table.remove(self.instructionalButtons, i)
				break
			end
		end
	else
		if tonumber(button) then
			if self.instructionalButtons[tonumber(button)] then
				table.remove(self.instructionalButtons, tonumber(button))
			end
		end
	end
end

function Menu:addEnabledControl(Inputgroup, Control, Controller)
    if tonumber(Inputgroup) and tonumber(Control) then
        table.insert(self.settings.enabledControls[(Controller and "Controller" or "Keyboard")], {Inputgroup, Control})
    end
end

function Menu:removeEnabledControl(inputgroup, control, controller)
    local Type = (controller and "Controller" or "Keyboard")
    for index = 1, #self.settings.enabledControls[Type] do
        if inputgroup == self.settings.enabledControls[Type][index][1] and control == self.settings.enabledControls[Type][index][2] then
            table.remove(self.settings.enabledControls[Type], index)
            break
        end
    end
end

function Menu:updateScaleform()
	if not self._visible or not self.settings.instructionalButtons then
		return
	end
	
	PushScaleformMovieFunction(self.instructionalScaleform, "CLEAR_ALL")
	PopScaleformMovieFunction()

	PushScaleformMovieFunction(self.instructionalScaleform, "TOGGLE_MOUSE_BUTTONS")
	PushScaleformMovieFunctionParameterInt(0)
	PopScaleformMovieFunction()

	PushScaleformMovieFunction(self.instructionalScaleform, "CREATE_CONTAINER")
	PopScaleformMovieFunction()

	PushScaleformMovieFunction(self.instructionalScaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterString(GetControlInstructionalButton(2, 176, 0))
	PushScaleformMovieFunctionParameterString("Select")
	PopScaleformMovieFunction()

	if self.controls.Back.enabled then
		PushScaleformMovieFunction(self.instructionalScaleform, "SET_DATA_SLOT")
		PushScaleformMovieFunctionParameterInt(1)
		PushScaleformMovieFunctionParameterString(GetControlInstructionalButton(2, 177, 0))
		PushScaleformMovieFunctionParameterString("Back")
		PopScaleformMovieFunction()
    	end

	local count = 2

	for i = 1, #self.instructionalButtons do
		if self.instructionalButtons[i] then
			if #self.instructionalButtons[i] == 2 then
				PushScaleformMovieFunction(self.instructionalScaleform, "SET_DATA_SLOT")
				PushScaleformMovieFunctionParameterInt(count)
				PushScaleformMovieFunctionParameterString(self.instructionalButtons[i][1])
				PushScaleformMovieFunctionParameterString(self.instructionalButtons[i][2])
				PopScaleformMovieFunction()
				count = count + 1
			end
		end
	end

	PushScaleformMovieFunction(self.instructionalScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
	PushScaleformMovieFunctionParameterInt(-1)
	PopScaleformMovieFunction()
end
