module.streaming = module.streaming or {};

module.streaming.RequestModel = function(modelHash)
	if type(modelHash) ~= "number" then
		modelHash = GetHashKey(modelHash);
	end

	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash);

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0);
		end
	end
end

module.streaming.RequestStreamedTextureDict = function(textureDict)
	if not HasStreamedTextureDictLoaded(textureDict) then
		RequestStreamedTextureDict(textureDict)

		while not HasStreamedTextureDictLoaded(textureDict) do
			Citizen.Wait(0);
		end
	end
end

module.streaming.RequestNamedPtfxAsset = function(assetName)
	if not HasNamedPtfxAssetLoaded(assetName) then
		RequestNamedPtfxAsset(assetName)

		while not HasNamedPtfxAssetLoaded(assetName) do
			Citizen.Wait(0);
		end
	end
end

module.streaming.RequestAnimSet = function(animSet)
	if not HasAnimSetLoaded(animSet) then
		RequestAnimSet(animSet)

		while not HasAnimSetLoaded(animSet) do
			Citizen.Wait(0);
		end
	end
end

module.streaming.RequestAnimDict = function(animDict)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(0);
		end
	end
end

module.streaming.RequestWeaponAsset = function(weaponHash)
	if not HasWeaponAssetLoaded(weaponHash) then
		RequestWeaponAsset(weaponHash)

		while not HasWeaponAssetLoaded(weaponHash) do
			Citizen.Wait(0);
		end
	end
end