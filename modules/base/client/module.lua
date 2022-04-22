local event = M("event");

-- Disable default idle camera
Citizen.CreateThread(function()
	while true do
		InvalidateIdleCam();
		InvalidateVehicleIdleCam();
		Wait(15000);
	end
end);

Citizen.CreateThread(function()
    while true do
		if NetworkIsSessionStarted() then
			event.emitShared("base:playerJoined");

			if IsScreenFadedOut() then
				DoScreenFadeIn();
			end

			return;
		end
		Citizen.Wait(100);
    end
end);

-- disable wanted level
ClearPlayerWantedLevel(PlayerId());
SetMaxWantedLevel(0);