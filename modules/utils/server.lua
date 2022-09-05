local logger = M("core").logger;
local event = M("core").event;

module.getIdentifier = function(playerId)
	for k,v in pairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, "license:") then
			return string.gsub(v, "license:", "");
		end
	end

	return nil;
end
