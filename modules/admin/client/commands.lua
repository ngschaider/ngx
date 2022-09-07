RegisterCommand("getcoords", function()
    local ped = PlayerPedId();

    local pos = GetEntityCoords(ped);
    print(pos.x .. " " .. pos.y .. " " .. pos.z);
end);