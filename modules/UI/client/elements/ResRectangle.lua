ResRectangle = setmetatable({}, ResRectangle)
ResRectangle.__index = ResRectangle
ResRectangle.__call = function() return "Rectangle" end

function ResRectangle:new(X, Y, Width, height, R, G, B, A)
	local _ResRectangle = {
		X = tonumber(X) or 0,
		Y = tonumber(Y) or 0,
		Width = tonumber(Width) or 0,
		height = tonumber(height) or 0,
		_Color = {R = tonumber(R) or 255, G = tonumber(G) or 255, B = tonumber(B) or 255, A = tonumber(A) or 255},
	}
	return setmetatable(_ResRectangle, ResRectangle)
end

function ResRectangle:position(X, Y)
	if tonumber(X) and tonumber(Y) then
		self.x = tonumber(X)
		self.y = tonumber(Y)
	else
		return {X = self.x, Y = self.y}
	end
end

function ResRectangle:Size(Width, height)
	if tonumber(Width) and tonumber(height) then
		self.width = tonumber(Width)
		self.height = tonumber(height)
	else
		return {Width = self.width, height = self.height}
	end
end

function ResRectangle:color(R, G, B, A)
    if tonumber(R) or tonumber(G) or tonumber(B) or tonumber(A) then
        self._Color.R = tonumber(R) or 255
        self._Color.B = tonumber(B) or 255
        self._Color.G = tonumber(G) or 255
        self._Color.A = tonumber(A) or 255
    else
    	return self._Color
    end
end

function ResRectangle:draw()
	local Position = self:position()
	local Size = self:Size()
	Size.Width, Size.height = FormatXWYH(Size.Width, Size.height)
    Position.X, Position.Y = FormatXWYH(Position.X, Position.Y)
	DrawRect(Position.X + Size.Width * 0.5, Position.Y + Size.height * 0.5, Size.Width, Size.height, self._Color.R, self._Color.G, self._Color.B, self._Color.A)
end

function DrawRectangle(X, Y, Width, height, R, G, B, A)
    X, Y, Width, height = X or 0, Y or 0, Width or 0, height or 0
    X, Y = FormatXWYH(X, Y)
    Width, height = FormatXWYH(Width, height)
    DrawRect(X + Width * 0.5, Y + height * 0.5, Width, height, tonumber(R) or 255, tonumber(G) or 255, tonumber(B) or 255, tonumber(A) or 255)
end