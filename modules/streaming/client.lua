module.RequestModel = function(modelHash, cb)
	if type(modelHash) ~= "number" then
		modelHash = GetHashKey(modelHash);
	end

	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash);

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0);
		end
	end

	if cb ~= nil then
		cb();
	end
end

module.RequestStreamedTextureDict = function(textureDict, cb)
	if not HasStreamedTextureDictLoaded(textureDict) then
		RequestStreamedTextureDict(textureDict)

		while not HasStreamedTextureDictLoaded(textureDict) do
			Citizen.Wait(0);
		end
	end

	if cb ~= nil then
		cb();
	end
end

module.RequestNamedPtfxAsset = function(assetName, cb)
	if not HasNamedPtfxAssetLoaded(assetName) then
		RequestNamedPtfxAsset(assetName)

		while not HasNamedPtfxAssetLoaded(assetName) do
			Citizen.Wait(0);
		end
	end

	if cb ~= nil then
		cb();
	end
end

module.RequestAnimSet = function(animSet, cb)
	if not HasAnimSetLoaded(animSet) then
		RequestAnimSet(animSet)

		while not HasAnimSetLoaded(animSet) do
			Citizen.Wait(0);
		end
	end

	if cb ~= nil then
		cb();
	end
end

module.RequestAnimDict = function(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(0);
		end
	end

	if cb ~= nil then
		cb();
	end
end

module.RequestWeaponAsset = function(weaponHash, cb)
	if not HasWeaponAssetLoaded(weaponHash) then
		RequestWeaponAsset(weaponHash)

		while not HasWeaponAssetLoaded(weaponHash) do
			Citizen.Wait(0);
		end
	end

	if cb ~= nil then
		cb();
	end
end