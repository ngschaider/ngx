local utils = M("utils");
local event = M("event");

CreateThread(function()
	local isDead = false;

	while true do
		Wait(0)
		local letSleep = 0
		local player = PlayerId()

		if NetworkIsPlayerActive(player) then
			local playerPed = PlayerPedId()

			if IsPedFatallyInjured(playerPed) and not isDead then
				letSleep = false
				isDead = true

				local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
				local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

				if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
					PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
				else
					PlayerKilled(deathCause)
				end

			elseif not IsPedFatallyInjured(playerPed) and isDead then
				letSleep = false
				isDead = false
			end
		end
		if letSleep then
			Wait(500)
		end
	end
end)

PlayerKilledByPlayer = function(killerServerId, killerClientId, deathCause)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance = #(victimCoords - killerCoords)

	local data = {
		victimCoords = {
			x = utils.math.Round(victimCoords.x, 1), 
			y = utils.math.Round(victimCoords.y, 1), 
			z = utils.math.Round(victimCoords.z, 1)
		};
		killerCoords = {
			x = utils.math.Round(killerCoords.x, 1), 
			y = utils.math.Round(killerCoords.y, 1), 
			z = utils.math.Round(killerCoords.z, 1)
		};

		killedByPlayer = true,
		deathCause = deathCause,
		distance = utils.math.Round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	event.emitShared("death:playerDied", data);
end

PlayerKilled = function(deathCause)
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(playerPed)

	local data = {
		victimCoords = {
			x = utils.math.Round(victimCoords.x, 1), 
			y = utils.math.Round(victimCoords.y, 1), 
			z = utils.math.Round(victimCoords.z, 1),
		};

		killedByPlayer = false,
		deathCause = deathCause
	}

	event.emitShared("death:playerDied", data);
end