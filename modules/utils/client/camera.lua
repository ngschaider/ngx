module.camera = module.camera or {};

local RotationToDirection = function(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	};
	local direction = {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	};
	return direction;
end;

module.camera.RaycastGameplayCamera = function()
    local camRot = GetGameplayCamRot();
    local camPos = GetGameplayCamCoord();
    local direction = RotationToDirection(camRot);
    local dest = {
        x = camPos.x + direction.x * distance,
        y = camPos.y + direction.y * distance,
        z = camPos.z + direction.z * distance
    };
	local handle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, -1, 1);
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(handle);
    return hit, endCoords, entityHit;
end