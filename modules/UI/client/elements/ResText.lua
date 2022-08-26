ResText = setmetatable({}, ResText)
ResText.__index = ResText
ResText.__call = function() return "Text" end

function GetCharacterCount(str)
    local characters = 0
    for c in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        local a = c:byte(1, -1)
        if a ~= nil then
            characters = characters + 1
        end
    end
    return characters
end

function GetByteCount(str)
    local bytes = 0

    for c in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        local a,b,c,d = c:byte(1, -1)
        if a ~= nil then
            bytes = bytes + 1
        end
        if b ~= nil then
            bytes = bytes + 1
        end
        if c ~= nil then
            bytes = bytes + 1
        end
        if d ~= nil then
            bytes = bytes + 1
        end
    end
    return bytes
end

function AddLongStringForAscii(str)
    local maxbytelength = 99
    for i = 0, GetCharacterCount(str), 99 do
        AddTextComponentSubstringPlayerName(string.sub(str, i, math.min(maxbytelength, GetCharacterCount(str) - i))) --needs changed
    end
end

function AddLongStringForUtf8(str)
    local maxbytelength = 99
    local bytecount = GetByteCount(str)

    if bytecount < maxbytelength then
        AddTextComponentSubstringPlayerName(str)
        return
    end

    local startIndex = 0

    for i = 0, GetCharacterCount(str), 1 do
        local length = i - startIndex
        if GetByteCount(string.sub(str, startIndex, length)) > maxbytelength then
            AddTextComponentSubstringPlayerName(string.sub(str, startIndex, length - 1))
            i = i - 1
            startIndex = startIndex + (length - 1)
        end
    end
    AddTextComponentSubstringPlayerName(string.sub(str, startIndex, GetCharacterCount(str) - startIndex))
end 

function AddLongString(str)
    local bytecount = GetByteCount(str)
    if bytecount == GetCharacterCount(str) then
        AddLongStringForAscii(str)
    else
        AddLongStringForUtf8(str)
    end
end

function MeasureStringWidthNoConvert(str, font, scale)
    BeginTextCommandWidth("STRING")
    AddLongString(str)
    SetTextFont(font or 0)
    SetTextScale(1.0, scale or 0)
    return EndTextCommandGetWidth(true)
end

function MeasureStringWidth(str, font, scale)
    return MeasureStringWidthNoConvert(str, font, scale) * 1920
end

function ResText:new(Text, X, Y, Scale, R, G, B, A, Font, Alignment, DropShadow, Outline, WordWrap)
	local _ResText = {
        _Text = tostring(Text) or "",
        X = tonumber(X) or 0,
        Y = tonumber(Y) or 0,
        Scale = tonumber(Scale) or 0,
        _Color = {R = tonumber(R) or 255, G = tonumber(G) or 255, B = tonumber(B) or 255, A = tonumber(A) or 255},
        Font = tonumber(Font) or 0,
        Alignment = Alignment or nil,
        DropShadow = Dropshadow or nil,
        Outline = Outline or nil,
        WordWrap = tonumber(WordWrap) or 0,
    }
	return setmetatable(_ResText, ResText)
end

function ResText:position(X, Y)
    if tonumber(X) and tonumber(Y) then
        self.x = tonumber(X)
        self.y = tonumber(Y)
    else
        return {X = self.x, Y = self.y}
    end
end

function ResText:color(R, G, B, A)
    if tonumber(R) and tonumber(G) and tonumber(B) and tonumber(A) then
        self._Color.R = tonumber(R)
        self._Color.B = tonumber(B)
        self._Color.G = tonumber(G)
        self._Color.A = tonumber(A)
    else
        return self._Color
    end
end

function ResText:Text(Text)
    if tostring(Text) and Text ~= nil then
        self._Text = tostring(Text)
    else
        return self._Text
    end
end

function ResText:draw()
    local Position = self:position()
    Position.X, Position.Y = FormatXWYH(Position.X, Position.Y)

    SetTextFont(self.font)
    SetTextScale(1.0, self.scale)
    SetTextColor(self._Color.R, self._Color.G, self._Color.B, self._Color.A)

    if self.dropShadow then
        SetTextDropShadow()
    end
    if self.outline then
        SetTextOutline()
    end

    if self.alignment ~= nil then
        if self.alignment == 1 or self.alignment == "Center" or self.alignment == "Centre" then
            SetTextCentre(true)
        elseif self.alignment == 2 or self.alignment == "Right" then
            SetTextRightJustify(true)
            SetTextWrap(0, Position.X)
        end
    end

    if tonumber(self.wordWrap) then
        if tonumber(self.wordWrap) ~= 0 then
            SetTextWrap(Position.X, Position.X + (tonumber(self.wordWrap) / Resolution.Width))
        end
    end

    BeginTextCommandDisplayText("STRING")
    AddLongString(self._Text)
    EndTextCommandDisplayText(Position.X, Position.Y)
end

function RenderText(Text, X, Y, Font, Scale, R, G, B, A, Alignment, DropShadow, Outline, WordWrap)
    Text = tostring(Text)
    X, Y = FormatXWYH(X, Y)
    SetTextFont(Font or 0)
    SetTextScale(1.0, Scale or 0)
    SetTextColor(R or 255, G or 255, B or 255, A or 255)

    if DropShadow then
        SetTextDropShadow()
    end
    if Outline then
        SetTextOutline()
    end

    if Alignment ~= nil then
        if Alignment == 1 or Alignment == "Center" or Alignment == "Centre" then
            SetTextCentre(true)
        elseif Alignment == 2 or Alignment == "Right" then
            SetTextRightJustify(true)
            SetTextWrap(0, X)
        end
    end

    if tonumber(WordWrap) then
        if tonumber(WordWrap) ~= 0 then
            WordWrap, _ = FormatXWYH(WordWrap, 0)
            SetTextWrap(WordWrap, X - WordWrap)
        end
    end

    BeginTextCommandDisplayText("STRING")
    AddLongString(Text)
    EndTextCommandDisplayText(X, Y)
end