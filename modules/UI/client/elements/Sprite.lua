Sprite = setmetatable({}, Sprite)
Sprite.__index = Sprite
Sprite.__call = function() return "Sprite" end

function Sprite:new(TxtDictionary, TxtName, X, Y, Width, height, Heading, R, G, B, A)
	local _Sprite = {
		TxtDictionary = tostring(TxtDictionary),
		TxtName = tostring(TxtName),
		X = tonumber(X) or 0,
		Y = tonumber(Y) or 0,
		Width = tonumber(Width) or 0, 
		height = tonumber(height) or 0,
		Heading = tonumber(Heading) or 0,
		_Color = {R = tonumber(R) or 255, G = tonumber(G) or 255, B = tonumber(B) or 255, A = tonumber(A) or 255},
	}
	return setmetatable(_Sprite, Sprite)
end

function Sprite:position(X, Y)
	if tonumber(X) and tonumber(Y) then
		self.x = tonumber(X)
		self.y = tonumber(Y)
	else
		return {X = self.x, Y = self.y}
	end
end

function Sprite:Size(Width, height)
	if tonumber(Width) and tonumber(Width) then
		self.width = tonumber(Width)
		self.height = tonumber(height)
	else
		return {Width = self.width, height = self.height}
	end
end

function Sprite:color(R, G, B, A)
    if tonumber(R) or tonumber(G) or tonumber(B) or tonumber(A) then
        self._Color.R = tonumber(R) or 255
        self._Color.B = tonumber(B) or 255
        self._Color.G = tonumber(G) or 255
        self._Color.A = tonumber(A) or 255
    else
    	return self._Color
    end
end

function Sprite:draw()
	if not HasStreamedTextureDictLoaded(self.txtDictionary) then
		RequestStreamedTextureDict(self.txtDictionary, true)
	end
	local Position = self:position()
	local Size = self:Size()
	Size.Width, Size.height = FormatXWYH(Size.Width, Size.height)
    Position.X, Position.Y = FormatXWYH(Position.X, Position.Y)
	DrawSprite(self.txtDictionary, self.txtName, Position.X + Size.Width * 0.5, Position.Y + Size.height * 0.5, Size.Width, Size.height, self.heading, self._Color.R, self._Color.G, self._Color.B, self._Color.A)
end

function DrawTexture(TxtDictionary, TxtName, X, Y, Width, height, Heading, R, G, B, A)
	if not HasStreamedTextureDictLoaded(tostring(TxtDictionary) or "") then
		RequestStreamedTextureDict(tostring(TxtDictionary) or "", true)
	end
	X, Y, Width, height = X or 0, Y or 0, Width or 0, height or 0
    X, Y = FormatXWYH(X, Y)
    Width, height = FormatXWYH(Width, height)
	DrawSprite(tostring(TxtDictionary) or "", tostring(TxtName) or "", X + Width * 0.5, Y + height * 0.5, Width, height, tonumber(Heading) or 0, tonumber(R) or 255, tonumber(G) or 255, tonumber(B) or 255, tonumber(A) or 255)
end