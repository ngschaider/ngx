run("shared/date.lua");
run("shared/math.lua");
run("shared/table.lua");

local uppercaseCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
local lowercaseCharacters = "abcdefghijklmnopqrstuvwxyz";
local numbers = "0123456789";

module.GetRandomFromCharset = function(length, charset)
	Citizen.Wait(0);
	math.randomseed(GetGameTimer());

	if length > 0 then
        local randomNumber = math.random(1, charset:len());
		return module.GetRandomFromCharset(length - 1, charset) .. charset:sub(randomNumber, randomNumber);
	else
		return "";
	end
end;

module.GeneratePlate = function()
	local firstHalf = module.GetRandomFromCharset(3, uppercaseCharacters);
	local secondHalf = module.GetRandomFromCharset(3, numbers);

	return firstHalf .. " " .. secondHalf;
end