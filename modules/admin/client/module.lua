local callback = M("callback");
local notification = M("notification");
local event = M("event");
local notification = M("notification");
local utils = M("utils");

event.onServer("admin:tpm", function()
	local blipMarker = GetFirstBlipInfoId(8);

	if not DoesBlipExist(blipMarker) then
		notification.showNotification("Kein Wegpunkt gesetzt.", true, false, 140);
		return;
	end

	local coords = GetBlipInfoIdCoord(blipMarker);
	utils.teleport(coords);
end)

event.onServer("admin:printCoords", function()
	local pos = GetEntityCoords(PlayerPedId());
	print(pos.x, pos.y, pos.z);
end);

local noclip = false;
event.onServer("admin:noclip", function(input)
	local player = PlayerId();

	local msg = "disabled";
	if not noclip then
		noclip_pos = GetEntityCoords(PlayerPedId(), false);
	end

	noclip = not noclip;

	if noclip then
		msg = "enabled";
	end

	notification.showNotification("Noclip has been ^2^*" .. msg);
end)

local heading = 0
CreateThread(function()
	while true do
		Citizen.Wait(0)

		if noclip then
			SetEntityCoordsNoOffset(PlayerPedId(), noclip_pos.x, noclip_pos.y, noclip_pos.z, 0, 0, 0)

			if(IsControlPressed(1, 34))then
				heading = heading + 1.5
				if heading > 360 then
					heading = 0
				end

				SetEntityHeading(PlayerPedId(), heading)
			end

			if(IsControlPressed(1, 9))then
				heading = heading - 1.5
				if heading < 0 then
					heading = 360
				end

				SetEntityHeading(PlayerPedId(), heading)
			end

			if(IsControlPressed(1, 8))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)
			end

			if(IsControlPressed(1, 32))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -1.0, 0.0)
			end

			if(IsControlPressed(1, 27))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, 1.0)
			end

			if(IsControlPressed(1, 173))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -1.0)
			end
		else
			Wait(200)
		end
	end
end)

event.onServer("admin:killPlayer", function()
  SetEntityHealth(PlayerPedId(), 0)
end)

event.onServer("admin:freezePlayer", function(freeze)
    local player = PlayerId();
	local playerPed = PlayerPedId();

	SetEntityCollision(playerPed, not freeze);
	FreezeEntityPosition(playerPed, freeze);
	SetPlayerInvincible(player, freeze);
end)