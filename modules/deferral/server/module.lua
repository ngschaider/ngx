local utils = M("utils");
local userClass = M("user");

AddEventHandler("playerConnecting", function(name, setCallback, deferrals)
	deferrals.defer();
	local playerId = source;
	local identifier = utils.getIdentifier(playerId);

	-- mandatory wait!
	Citizen.Wait(0); 

	if identifier then
		local user = userClass.getByIdentifier(identifier);
		if user.getIsOnline() then
			deferrals.done("There was an error loading your character!\nError code: identifier-active\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same account.\n\nYour identifier: " .. identifier);
		else
			deferrals.done();
		end
	else
		deferrals.done("There was an error loading your character!\nError code: identifier-missing\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.");
	end
end)