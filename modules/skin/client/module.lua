local utils = M("utils");
local logger = M("logger");
local event = M("event");
local characterClass = M("character");
local callback = M("callback");

callback.register("skin:getSkin", function(cb)
	cb(module.getSkin());
end);

event.on("character:construct:after", function(character)
	character.getSkin = function(cb)
		character.rpc("getSkin", cb);
	end;
	
	character.setSkin = function(skin, cb)
		character.rpc("setSkin", cb, skin);
	end;
end);

local components = {
	{name = "sex", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "mom", value = 21, min = 21, zoomOffset = 0.6, camOffset = 0.65},
	{name = "dad", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "face_md_weight", value = 50, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "skin_md_weight", value = 50, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "nose_1", value = 0, min = -10, zoomOffset = 0.6, camOffset = 0.65},
	{name = "nose_2", value = 0, min = -10, zoomOffset = 0.6, camOffset = 0.65},
	{name = "nose_3", value = 0, min = -10, zoomOffset = 0.6, camOffset = 0.65},
	{name = "nose_4", value = 0, min = -10, zoomOffset = 0.6, camOffset = 0.65},
	{name = "nose_5", value = 0, min = -10, zoomOffset = 0.6, camOffset = 0.65},
	{name = "nose_6", value = 0, min = -10, zoomOffset = 0.6, camOffset = 0.65},
	{name = "cheeks_1", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "cheeks_2", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "cheeks_3", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "lip_thickness", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "jaw_1", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "jaw_2", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "chin_1", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "chin_2", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "chin_3", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "chin_4", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "neck_thickness", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "hair_1", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "hair_2", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "hair_color_1", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "hair_color_2", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "tshirt_1", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, componentId = 8},
	{name = "tshirt_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = "tshirt_1"},
	{name = "torso_1", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, componentId = 11},
	{name = "torso_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = "torso_1"},
	{name = "decals_1", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, componentId = 10},
	{name = "decals_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = "decals_1"},
	{name = "arms", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15},
	{name = "arms_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15},
	{name = "pants_1", value = 0, min = 0, zoomOffset = 0.8, camOffset = -0.5, componentId = 4},
	{name = "pants_2", value = 0, min = 0, zoomOffset = 0.8, camOffset = -0.5, textureof = "pants_1"},
	{name = "shoes_1", value = 0, min = 0, zoomOffset = 0.8, camOffset = -0.8, componentId = 6},
	{name = "shoes_2", value = 0, min = 0, zoomOffset = 0.8, camOffset = -0.8, textureof = "shoes_1"},
	{name = "mask_1", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, componentId = 1},
	{name = "mask_2", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, textureof = "mask_1"},
	{name = "bproof_1", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, componentId = 9},
	{name = "bproof_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = "bproof_1"},
	{name = "chain_1", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, componentId = 7},
	{name = "chain_2", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, textureof = "chain_1"},
	{name = "helmet_1", value = -1, min = -1, zoomOffset = 0.6, camOffset = 0.65, componentId = 0 },
	{name = "helmet_2", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, textureof = "helmet_1"},
	{name = "glasses_1", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, componentId = 1},
	{name = "glasses_2", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, textureof = "glasses_1"},
	{name = "watches_1", value = -1, min = -1, zoomOffset = 0.75, camOffset = 0.15, componentId = 6},
	{name = "watches_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = "watches_1"},
	{name = "bracelets_1", value = -1, min = -1, zoomOffset = 0.75, camOffset = 0.15, componentId = 7},
	{name = "bracelets_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = "bracelets_1"},
	{name = "bags_1", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, componentId = 5},
	{name = "bags_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = "bags_1"},
	{name = "eye_color", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "eye_squint", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "eyebrows_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "eyebrows_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "eyebrows_3", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "eyebrows_4", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "eyebrows_5", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "eyebrows_6", value = 0, min = -10, zoomOffset = 0.4, camOffset = 0.65},
	{name = "makeup_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "makeup_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "makeup_3", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "makeup_4", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "lipstick_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "lipstick_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "lipstick_3", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "lipstick_4", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "ears_1", value = -1, min = -1, zoomOffset = 0.4, camOffset = 0.65, componentId = 2},
	{name = "ears_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65, textureof = "ears_1"},
	{name = "chest_1", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15},
	{name = "chest_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15},
	{name = "chest_3", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15},
	{name = "bodyb_1", value = -1, min = -1, zoomOffset = 0.75, camOffset = 0.15},
	{name = "bodyb_2", value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15},
	{name = "bodyb_3", value = -1, min = -1, zoomOffset = 0.4, camOffset = 0.15},
	{name = "bodyb_4", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.15},
	{name = "age_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "age_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "blemishes_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "blemishes_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "blush_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "blush_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "blush_3", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "complexion_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "complexion_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "sun_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "sun_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "moles_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "moles_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "beard_1", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "beard_2", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "beard_3", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65},
	{name = "beard_4", value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}
}

local lastSex = -1
local character = {}

for i=1, #components, 1 do
	character[components[i].name] = components[i].value
end

module.loadDefaultModel = function(malePed)
	local model;
	if malePed then
		model = GetHashKey("mp_m_freemode_01");
	else
		model = GetHashKey("mp_f_freemode_01");
	end

	RequestModel(model);

	Citizen.CreateThread(function()
		while not HasModelLoaded(model) do
			RequestModel(model);
			Citizen.Wait(0);
		end

		if IsModelInCdimage(model) and IsModelValid(model) then
			SetPlayerModel(PlayerId(), model);
			SetPedDefaultComponentVariation(PlayerPedId());
		end

		SetModelAsNoLongerNeeded(model);
	end)
end

local GetMaxVals = function()
	local playerPed = PlayerPedId()

	local data = {
		sex = 1,
		mom = 45, -- numbers 21-41 and 45 are female (22 total)
		dad = 44, -- numbers 0-20 and 42-44 are male (24 total)
		face_md_weight = 100,
		skin_md_weight = 100,
		nose_1 = 10,
		nose_2 = 10,
		nose_3 = 10,
		nose_4 = 10,
		nose_5 = 10,
		nose_6 = 10,
		cheeks_1 = 10,
		cheeks_2 = 10,
		cheeks_3 = 10,
		lip_thickness = 10,
		jaw_1 = 10,
		jaw_2 = 10,
		chin_1 = 10,
		chin_2 = 10,
		chin_3 = 10,
		chin_4 = 10,
		neck_thickness = 10,
		age_1 = GetPedHeadOverlayNum(3)-1,
		age_2 = 10,
		beard_1 = GetPedHeadOverlayNum(1)-1,
		beard_2 = 10,
		beard_3 = GetNumHairColors()-1,
		beard_4 = GetNumHairColors()-1,
		hair_1 = GetNumberOfPedDrawableVariations (playerPed, 2) - 1,
		hair_2 = GetNumberOfPedTextureVariations (playerPed, 2, character["hair_1"]) - 1,
		hair_color_1 = GetNumHairColors()-1,
		hair_color_2 = GetNumHairColors()-1,
		eye_color = 31,
		eye_squint = 10,
		eyebrows_1 = GetPedHeadOverlayNum(2)-1,
		eyebrows_2 = 10,
		eyebrows_3 = GetNumHairColors()-1,
		eyebrows_4 = GetNumHairColors()-1,
		eyebrows_5 = 10,
		eyebrows_6 = 10,
		makeup_1 = GetPedHeadOverlayNum(4)-1,
		makeup_2 = 10,
		makeup_3 = GetNumHairColors()-1,
		makeup_4 = GetNumHairColors()-1,
		lipstick_1 = GetPedHeadOverlayNum(8)-1,
		lipstick_2 = 10,
		lipstick_3 = GetNumHairColors()-1,
		lipstick_4 = GetNumHairColors()-1,
		blemishes_1 = GetPedHeadOverlayNum(0)-1,
		blemishes_2 = 10,
		blush_1 = GetPedHeadOverlayNum(5)-1,
		blush_2 = 10,
		blush_3 = GetNumHairColors()-1,
		complexion_1 = GetPedHeadOverlayNum(6)-1,
		complexion_2 = 10,
		sun_1 = GetPedHeadOverlayNum(7)-1,
		sun_2 = 10,
		moles_1 = GetPedHeadOverlayNum(9)-1,
		moles_2 = 10,
		chest_1 = GetPedHeadOverlayNum(10)-1,
		chest_2 = 10,
		chest_3 = GetNumHairColors()-1,
		bodyb_1 = GetPedHeadOverlayNum(11)-1,
		bodyb_2 = 10,
		bodyb_3 = GetPedHeadOverlayNum(12)-1,
		bodyb_4 = 10,
		ears_1 = GetNumberOfPedPropDrawableVariations (playerPed, 2) - 1,
		ears_2 = GetNumberOfPedPropTextureVariations (playerPed, 2, character["ears_1"] - 1),
		tshirt_1 = GetNumberOfPedDrawableVariations (playerPed, 8) - 1,
		tshirt_2 = GetNumberOfPedTextureVariations (playerPed, 8, character["tshirt_1"]) - 1,
		torso_1 = GetNumberOfPedDrawableVariations (playerPed, 11) - 1,
		torso_2 = GetNumberOfPedTextureVariations (playerPed, 11, character["torso_1"]) - 1,
		decals_1 = GetNumberOfPedDrawableVariations (playerPed, 10) - 1,
		decals_2 = GetNumberOfPedTextureVariations (playerPed, 10, character["decals_1"]) - 1,
		arms = GetNumberOfPedDrawableVariations (playerPed, 3) - 1,
		arms_2 = 10,
		pants_1 = GetNumberOfPedDrawableVariations (playerPed, 4) - 1,
		pants_2 = GetNumberOfPedTextureVariations (playerPed, 4, character["pants_1"]) - 1,
		shoes_1 = GetNumberOfPedDrawableVariations (playerPed, 6) - 1,
		shoes_2 = GetNumberOfPedTextureVariations (playerPed, 6, character["shoes_1"]) - 1,
		mask_1 = GetNumberOfPedDrawableVariations (playerPed, 1) - 1,
		mask_2 = GetNumberOfPedTextureVariations (playerPed, 1, character["mask_1"]) - 1,
		bproof_1 = GetNumberOfPedDrawableVariations (playerPed, 9) - 1,
		bproof_2 = GetNumberOfPedTextureVariations (playerPed, 9, character["bproof_1"]) - 1,
		chain_1 = GetNumberOfPedDrawableVariations (playerPed, 7) - 1,
		chain_2 = GetNumberOfPedTextureVariations (playerPed, 7, character["chain_1"]) - 1,
		bags_1 = GetNumberOfPedDrawableVariations (playerPed, 5) - 1,
		bags_2 = GetNumberOfPedTextureVariations (playerPed, 5, character["bags_1"]) - 1,
		helmet_1 = GetNumberOfPedPropDrawableVariations (playerPed, 0) - 1,
		helmet_2 = GetNumberOfPedPropTextureVariations (playerPed, 0, character["helmet_1"]) - 1,
		glasses_1 = GetNumberOfPedPropDrawableVariations (playerPed, 1) - 1,
		glasses_2 = GetNumberOfPedPropTextureVariations (playerPed, 1, character["glasses_1"] - 1),
		watches_1 = GetNumberOfPedPropDrawableVariations (playerPed, 6) - 1,
		watches_2 = GetNumberOfPedPropTextureVariations (playerPed, 6, character["watches_1"]) - 1,
		bracelets_1 = GetNumberOfPedPropDrawableVariations (playerPed, 7) - 1,
		bracelets_2 = GetNumberOfPedPropTextureVariations (playerPed, 7, character["bracelets_1"] - 1)
	}

	return data;
end

module.applySkin = function(skin, clothes)
	local playerPed = PlayerPedId()

	for k,v in pairs(skin) do
		character[k] = v
	end

	if clothes ~= nil then
		for k,v in pairs(clothes) do
			if
				k ~= "sex" and
				k ~= "mom" and
				k ~= "dad" and
				k ~= "face_md_weight" and
				k ~= "skin_md_weight" and
				k ~= "nose_1" and
				k ~= "nose_2" and
				k ~= "nose_3" and
				k ~= "nose_4" and
				k ~= "nose_5" and
				k ~= "nose_6" and
				k ~= "cheeks_1" and
				k ~= "cheeks_2" and
				k ~= "cheeks_3" and
				k ~= "lip_thickness" and
				k ~= "jaw_1" and
				k ~= "jaw_2" and
				k ~= "chin_1" and
				k ~= "chin_2" and
				k ~= "chin_3" and
				k ~= "chin_4" and
				k ~= "neck_thickness" and
				k ~= "age_1" and
				k ~= "age_2" and
				k ~= "eye_color" and
				k ~= "eye_squint" and
				k ~= "beard_1" and
				k ~= "beard_2" and
				k ~= "beard_3" and
				k ~= "beard_4" and
				k ~= "hair_1" and
				k ~= "hair_2" and
				k ~= "hair_color_1" and
				k ~= "hair_color_2" and
				k ~= "eyebrows_1" and
				k ~= "eyebrows_2" and
				k ~= "eyebrows_3" and
				k ~= "eyebrows_4" and
				k ~= "eyebrows_5" and
				k ~= "eyebrows_6" and
				k ~= "makeup_1" and
				k ~= "makeup_2" and
				k ~= "makeup_3" and
				k ~= "makeup_4" and
				k ~= "lipstick_1" and
				k ~= "lipstick_2" and
				k ~= "lipstick_3" and
				k ~= "lipstick_4" and
				k ~= "blemishes_1" and
				k ~= "blemishes_2" and
				k ~= "blemishes_3" and
				k ~= "blush_1" and
				k ~= "blush_2" and
				k ~= "blush_3" and
				k ~= "complexion_1" and
				k ~= "complexion_2" and
				k ~= "sun_1" and
				k ~= "sun_2" and
				k ~= "moles_1" and
				k ~= "moles_2" and
				k ~= "chest_1" and
				k ~= "chest_2" and
				k ~= "chest_3" and
				k ~= "bodyb_1" and
				k ~= "bodyb_2" and
				k ~= "bodyb_3" and
				k ~= "bodyb_4"
			then
				character[k] = v
			end
		end
	end

	local face_weight = character.face_md_weight / 100 + 0.0;
	local skin_weight = character.skin_md_weight / 100 + 0.0;
	SetPedHeadBlendData(playerPed, character.mom, character.dad, 0, character.mom, character.dad, 0, face_weight, skin_weight, 0.0, false);

	SetPedFaceFeature(playerPed, 0, character.nose_1 / 10 + 0.0) -- Nose Width
	SetPedFaceFeature(playerPed, 1, character.nose_2 / 10 + 0.0) -- Nose Peak Height
	SetPedFaceFeature(playerPed, 2, character.nose_3 / 10 + 0.0) -- Nose Peak Length
	SetPedFaceFeature(playerPed, 3, character.nose_4 / 10 + 0.0) -- Nose Bone Height
	SetPedFaceFeature(playerPed, 4, character.nose_5 / 10 + 0.0) -- Nose Peak Lowering
	SetPedFaceFeature(playerPed, 5, character.nose_6 / 10 + 0.0) -- Nose Bone Twist
	SetPedFaceFeature(playerPed, 6, character.eyebrows_5 / 10 + 0.0) -- Eyebrow height
	SetPedFaceFeature(playerPed, 7, character.eyebrows_6 / 10 + 0.0) -- Eyebrow depth
	SetPedFaceFeature(playerPed, 8, character.cheeks_1 / 10 + 0.0) -- Cheekbones Height
	SetPedFaceFeature(playerPed, 9, character.cheeks_2 / 10 + 0.0) -- Cheekbones Width
	SetPedFaceFeature(playerPed, 10, character.cheeks_3 / 10 + 0.0) -- Cheeks Width
	SetPedFaceFeature(playerPed, 11, character.eye_squint / 10 + 0.0) -- Eyes squint
	SetPedFaceFeature(playerPed, 12, character.lip_thickness / 10 + 0.0) -- Lip Fullness
	SetPedFaceFeature(playerPed, 13, character.jaw_1 / 10 + 0.0) -- Jaw Bone Width
	SetPedFaceFeature(playerPed, 14, character.jaw_2 / 10 + 0.0) -- Jaw Bone Length
	SetPedFaceFeature(playerPed, 15, character.chin_1 / 10 + 0.0) -- Chin Height
	SetPedFaceFeature(playerPed, 16, character.chin_2 / 10 + 0.0) -- Chin Length
	SetPedFaceFeature(playerPed, 17, character.chin_3 / 10 + 0.0) -- Chin Width
	SetPedFaceFeature(playerPed, 18, character.chin_4 / 10 + 0.0) -- Chin Hole Size
	SetPedFaceFeature(playerPed, 19, character.neck_thickness / 10 + 0.0) -- Neck Thickness

	SetPedHairColor(playerPed, character.hair_color_1, character.hair_color_2) -- Hair Color
	SetPedHeadOverlay(playerPed, 3, character.age_1, character.age_2 / 10 + 0.0) -- Age + opacity
	SetPedHeadOverlay(playerPed, 0, character.blemishes_1, character.blemishes_2 / 10 + 0.0) -- Blemishes + opacity
	SetPedHeadOverlay(playerPed, 1, character.beard_1, character.beard_2 / 10 + 0.0) -- Beard + opacity
	SetPedEyeColor(playerPed, character.eye_color) -- Eyes color
	SetPedHeadOverlay(playerPed, 2, character.eyebrows_1, character.eyebrows_2 / 10 + 0.0) -- Eyebrows + opacity
	SetPedHeadOverlay(playerPed, 4, character.makeup_1, character.makeup_2 / 10 + 0.0) -- Makeup + opacity
	SetPedHeadOverlay(playerPed, 8, character.lipstick_1, character.lipstick_2 / 10 + 0.0) -- Lipstick + opacity
	SetPedComponentVariation(playerPed, 2, character.hair_1, character.hair_2, 2) -- Hair
	SetPedHeadOverlayColor(playerPed, 1, 1, character.beard_3, character.beard_4) -- Beard Color
	SetPedHeadOverlayColor(playerPed, 2, 1, character.eyebrows_3, character.eyebrows_4) -- Eyebrows Color
	SetPedHeadOverlayColor(playerPed, 4, 2, character.makeup_3, character.makeup_4) -- Makeup Color
	SetPedHeadOverlayColor(playerPed, 8, 1, character.lipstick_3, character.lipstick_4) -- Lipstick Color
	SetPedHeadOverlay(playerPed, 5, character.blush_1, character.blush_2 / 10 + 0.0) -- Blush + opacity
	SetPedHeadOverlayColor(playerPed, 5, 2, character.blush_3) -- Blush Color
	SetPedHeadOverlay(playerPed, 6, character.complexion_1, character.complexion_2 / 10 + 0.0) -- Complexion + opacity
	SetPedHeadOverlay(playerPed, 7, character.sun_1, character.sun_2 / 10 + 0.0) -- Sun Damage + opacity
	SetPedHeadOverlay(playerPed, 9, character.moles_1, character.moles_2 / 10 + 0.0) -- Moles/Freckles + opacity
	SetPedHeadOverlay(playerPed, 10, character.chest_1, character.chest_2 / 10 + 0.0) -- Chest Hair + opacity
	SetPedHeadOverlayColor(playerPed, 10, 1, character.chest_3) -- Torso Color

	if character.bodyb_1 == -1 then
		SetPedHeadOverlay(playerPed, 11, 255, character.bodyb_2 / 10 + 0.0) -- Body Blemishes + opacity
	else
		SetPedHeadOverlay(playerPed, 11, character.bodyb_1, character.bodyb_2 / 10 + 0.0)
	end

	if character.bodyb_3 == -1 then
		SetPedHeadOverlay(playerPed, 12, 255, character.bodyb_4 / 10 + 0.0)
	else
		SetPedHeadOverlay(playerPed, 12, character.bodyb_3, character.bodyb_4 / 10 + 0.0) -- Blemishes "added body effect" + opacity
	end

	if character.ears_1 == -1 then
		ClearPedProp(playerPed, 2)
	else
		SetPedPropIndex(playerPed, 2, character.ears_1, character.ears_2, 2) -- Ears Accessories
	end

	SetPedComponentVariation(playerPed, 8, character.tshirt_1, character.tshirt_2, 2) -- Tshirt
	SetPedComponentVariation(playerPed, 11, character.torso_1, character.torso_2, 2) -- torso parts
	SetPedComponentVariation(playerPed, 3, character.arms, character.arms_2, 2) -- Amrs
	SetPedComponentVariation(playerPed, 10, character.decals_1, character.decals_2, 2) -- decals
	SetPedComponentVariation(playerPed, 4, character.pants_1, character.pants_2, 2) -- pants
	SetPedComponentVariation(playerPed, 6, character.shoes_1, character.shoes_2, 2) -- shoes
	SetPedComponentVariation(playerPed, 1, character.mask_1, character.mask_2, 2) -- mask
	SetPedComponentVariation(playerPed, 9, character.bproof_1, character.bproof_2, 2) -- bulletproof
	SetPedComponentVariation(playerPed, 7, character.chain_1, character.chain_2, 2) -- chain
	SetPedComponentVariation(playerPed, 5, character.bags_1, character.bags_2, 2) -- Bag

	if character["helmet_1"] == -1 then
		ClearPedProp(playerPed, 0)
	else
		SetPedPropIndex (playerPed, 0, character.helmet_1, character.helmet_2, 2) -- Helmet
	end

	if character["glasses_1"] == -1 then
		ClearPedProp(playerPed, 1)
	else
		SetPedPropIndex (playerPed, 1, character.glasses_1, character.glasses_2, 2) -- Glasses
	end

	if character["watches_1"] == -1 then
		ClearPedProp(playerPed, 6)
	else
		SetPedPropIndex (playerPed, 6, character.watches_1, character.watches_2, 2) -- Watches
	end

	if character["bracelets_1"] == -1 then
		ClearPedProp(playerPed, 7)
	else
		SetPedPropIndex (playerPed, 7, character.bracelets_1, character.bracelets_2, 2) -- Bracelets
	end
end

module.getData = function()
    local ret = utils.table.clone(components);

	for k,v in pairs(character) do
		for i=1, #ret, 1 do
			if k == ret[i].name then
				ret[i].value = v;
			end
		end
	end

    return ret, GetMaxVals();
end;

module.change = function(key, val)
    character[key] = val

	if key == "sex" then
        module.loadSkin(character);
	else
		module.applySkin(character)
	end
end;


module.getSkin = function()
    return utils.table.clone(character);
end;

module.loadSkin = function(skin, cb)
	if skin["sex"] ~= lastSex then
		if skin["sex"] == 0 then
			module.loadDefaultModel(true, cb);
		else
            module.loadDefaultModel(false, cb);
		end
	else
		module.applySkin(skin)

		if cb ~= nil then
			cb()
		end
	end
end;

module.loadClothes = function(playerSkin, clothesSkin)
	if playerSkin["sex"] ~= lastSex then
		if playerSkin["sex"] == 0 then
			module.loadDefaultModel(true);
		else
			module.loadDefaultModel(false);
		end
	else
		module.applySkin(playerSkin, clothesSkin);
	end
end;