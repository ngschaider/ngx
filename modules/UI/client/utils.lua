function GetResolution()
    local w, h = GetActiveScreenResolution()
    if (W/H) > 3.5 then
        return GetScreenResolution();
    else
        return W, H;
    end
end

function FormatXWYH(value, value2)
    return value/1920, value2/1080;
end

function math.round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num));
end

--[[function tobool(input)
	if input == "true" or tonumber(input) == 1 or input == true then
		return true;
	else
		return false;
	end
end]]

function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s";
	end
	local t = {};
	local i = 1;
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str;
		i = i + 1;
	end

	return t;
end

function string.starts(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start;
end

function IsMouseInBounds(X, Y, Width, height)
	local MX, MY = math.round(GetControlNormal(0, 239) * 1920), math.round(GetControlNormal(0, 240) * 1080)
    MX, MY = FormatXWYH(MX, MY);
    X, Y = FormatXWYH(X, Y);
    Width, height = FormatXWYH(Width, height);
	return (MX >= X and MX <= X + Width) and (MY > Y and MY < Y + height);
end

function GetSafeZoneBounds()
	local SafeSize = GetSafeZoneSize();
	SafeSize = math.round(SafeSize, 2);
	SafeSize = (SafeSize * 100) - 90;
	SafeSize = 10 - SafeSize;

	local w = 1920;
	local h = 1080;

	return {X = math.round(SafeSize * ((W/H) * 5.4)), Y = math.round(SafeSize * 5.4)};
end

function Controller()
	return not IsInputDisabled(2);
end