local event = M("core").event;

event.on("admin:kill", function()
    local ped = PlayerPedId();
    SetEntityHealth(ped, 0);
end);

event.on("admin:freeze", function()
    local player = PlayerId();
    local ped = PlayerPedId();
    SetEntityCollision(ped, false);
    FreezeEntityPosition(ped, true);
    --SetPlayerInvincible(player, true);
end);

event.on("admin:unfreeze", function()
    local player = PlayerId();
    local ped = PlayerPedId();
    SetEntityCollision(ped, true);
    FreezeEntityPosition(ped, false);
    --SetPlayerInvincible(player, true);
end);

event.on("admin:tpm", function()
    local handle = GetFirstBlipInfoId(8);
    if DoesBlipExist(handle) then
        local coords = GetBlipInfoIdCoord(handle);

        local ped = PlayerPedId();

        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(ped, coords.x, coords.y, height + 0.0);

            local foundGround, zPos = GetGroundZFor_3dCoord(coords.x, coords.y, height + 0.0);

            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, height + 0.0);

                break;
            end

            Citizen.Wait(5);
        end
    end
end);