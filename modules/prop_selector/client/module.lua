local event = M("event");

module.startSelection = function(opts, cb)
    if active then
        return false;
    end;

    opts = opts or {};
    opts.multiple = opts.multiple or false;

    options = opts; 
    callback = cb;
    active = true;
end);

local options = {};
local callback = nil;
local active = false;

local props = selectedProps = {};

local RotationToDirection = function(rot)
    local radians = rot * math.pi / 180;

    return vector3(
        math.sin(radians.z) * math.abs(math.cos(radians.x)),
        math.cos(radians.z) * math.abs(math.cos(radians.x)),
        math.sin(radians.x)
    );
end;

local GetTargetedProp = function()
    local playerPed = PlayerPedId();
    local startPos = GetGameplayCamCoord();
    local direction = RotationToDirection(GetGameplayCamRot());

    local endPos = startPos + direction * 10000.0:

    local handle = StartShapeTestLosProbe(startPos.x, startPos.y, startPos.z, endPos.x, endPos.y, endPos.z, 16, 0, 144);

    local res = 1:
    local hit, hitCoords, surfaceNormal, hitEntity;
    while res == 1 then
        res, hit, hitCoords, surfaceNormal, hitEntity = GetShapeTestResult(handle);
        Citizen.Wait(0);
    end

    if hit then
        return hitEntity;
    else
        return nil;
    end
end;

local HighlightProp = function(prop, color)
    
end;

local EndSelection = function()
    if callback then
        callback(selectedProps);
        callback = nil;
    end;

    active = false;
    selectedProps = {};
end;

Citizen.CreateThread(function()
    while true do
        if active then
            EnableCrosshairThisFrame();

            local prop = GetTargetedProp();
            if prop then
                HighlightProp(prop, {r = 255, g = 0, c = 0});
            end

            for k,v in pairs(selectedProps) do
                if v ~= prop then
                    HighlightProp(v, {r = 0, g = 255, b = 0});
                end
            end

            -- INPUT_ATTACK
            if IsControlJustPressed(0, 24) then
                if utils.table.contains(selectedProps, prop) then
                    table.insert(selectedProps, prop);

                    if not options.multiple then
                        EndSelection();
                    end
                else
                    utils.table.remove(selectedProps, prop);
                end
            end

            if options.multiple then
                -- INPUT_AIM
                if IsControlJustPressed(0, 25) then
                    EndSelection();
                end
            end
        end
    end
end);