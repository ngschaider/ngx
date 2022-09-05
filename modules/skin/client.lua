local utils = M("utils");

-- constant lookup table for default values, minimum values, zoom and cam offsets
--[[
local components = {
	{name = "sex", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "mom", value = 21, min = 21, zoomOffset = 0.6, camOffset = 0.65},
	{name = "dad", value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "face_weight", value = 50, min = 0, zoomOffset = 0.6, camOffset = 0.65},
	{name = "skin_weight", value = 50, min = 0, zoomOffset = 0.6, camOffset = 0.65},
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
]]

--[[
-- returns an object which keys map to the maximum values
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
end;
]]

module.getValues = function()
	local playerPed = PlayerPedId();

	local headBlendData = exports.hbw:GetHeadBlendData(PlayerPedId());
	--print("getting", json.encode(headBlendData));

	local _, age, _, _, _, age_opacity = GetPedHeadOverlayData();

	local _, blemishes, _, _, _, blemishes_opacity = GetPedHeadOverlayData(playerPed, 0);
	local _, beard, _, beard_color1, beard_color2, beard_opacity = GetPedHeadOverlayData(playerPed, 1);
	local _, eyebrows, _, eyebrows_color1, eyebrows_color2, eyebrows_opacity = GetPedHeadOverlayData(playerPed, 2);
	local _, age, _, _, _, age_opacity = GetPedHeadOverlayData(playerPed, 3);
	local _, makeup, _, makeup_color1, makeup_color2, makeup_opacity = GetPedHeadOverlayData(playerPed, 4);
	local _, blush, _, blush_color, _, blush_opacity = GetPedHeadOverlayData(playerPed, 5);
	local _, complexion, _, _, _, complexion_opacity = GetPedHeadOverlayData(playerPed, 6);
	local _, sun_damage, _, _, _, sun_damage_opacity = GetPedHeadOverlayData(playerPed, 7);
	local _, lipstick, _, lipstick_color1, lipstick_color2, lipstick_opacity = GetPedHeadOverlayData(playerPed, 8);
	local _, moles, _, _, _, moles_opacity = GetPedHeadOverlayData(playerPed, 9);
	local _, chest_hair, _, chest_hair_color, _, chest_hair_opacity = GetPedHeadOverlayData(playerPed, 10);

	local _, body_blemishes, _, _, _, body_blemishes_opacity = GetPedHeadOverlayData(playerPed, 11);
	if body_blemishes == 255 then
		body_blemishes = -1;
	end

	local _, body_blemishes_effect, _, _, _, body_blemishes_effect_opacity = GetPedHeadOverlayData(playerPed, 12);
	if body_blemishes_effect == 255 then
		body_blemishes_effect = -1;
	end

	local skin = {
		-- head blend data
		mom = headBlendData.FirstFaceShape,
		dad = headBlendData.SecondFaceShape,
		face_weight = headBlendData.ParentFaceShapePercent,
		skin_weight = headBlendData.ParentSkinTonePercent,

		-- ped face features
		nose_width = GetPedFaceFeature(playerPed, 0),
		nose_peak = GetPedFaceFeature(playerPed, 1),
		nose_length = GetPedFaceFeature(playerPed, 2),
		nose_curveness = GetPedFaceFeature(playerPed, 3),
		nose_tip = GetPedFaceFeature(playerPed, 4),
		nose_twist = GetPedFaceFeature(playerPed, 5),
		eyebrows_height = GetPedFaceFeature(playerPed, 6),
		eyebrows_depth = GetPedFaceFeature(playerPed, 7),
		cheeks_height = GetPedFaceFeature(playerPed, 8),
		cheeks_width1 = GetPedFaceFeature(playerPed, 9),
		cheeks_width2 = GetPedFaceFeature(playerPed, 10),
		eye_opening = GetPedFaceFeature(playerPed, 11),
		lip_thickness = GetPedFaceFeature(playerPed, 12),
		jaw_width = GetPedFaceFeature(playerPed, 13),
		jaw_shape = GetPedFaceFeature(playerPed, 14),
		chin_height = GetPedFaceFeature(playerPed, 15),
		chin_length = GetPedFaceFeature(playerPed, 16),
		chin_width = GetPedFaceFeature(playerPed, 17),
		chin_hole = GetPedFaceFeature(playerPed, 18),
		neck_thickness = GetPedFaceFeature(playerPed, 19),

		-- hair color
		hair_color = GetPedHairColor(playerPed),
		hair_highlight_color = GetPedHairHighlightColor(playerPed),

		-- ped head overlay
		blemishes = blemishes,
		blemishes_opacity = blemishes_opacity,
		beard = beard,
		beard_opacity = beard_opacity,
		age = age,
		age_opacity = age_opacity,
		makeup = makeup,
		makeup_opacity = makeup_opacity,
		blush = blush,
		blush_opacity = blush_opacity,
		complexion = complexion,
		complexion_opacity = complexion_opacity,
		sun_damage = sun_damage,
		sun_damage_opacity = sun_damage_opacity,
		lipstick = lipstick,
		lipstick_opacity = lipstick_opacity,
		moles = moles,
		moles_opacity = moles_opacity,
		chest_hair = chest_hair,
		chest_hair_opacity = chest_hair_opacity,
		body_blemishes = body_blemishes,
		body_blemishes_opacity = body_blemishes_opacity,
		body_blemishes_effect = body_blemishes_effect,
		body_blemishes_effect_opacity = body_blemishes_effect_opacity,

		-- ped head overlay data color
		beard_color1 = beard_color1,
		beard_color2 = beard_color2,
		eyebrows_color1 = eyebrows_color1,
		eyebrows_color2 = eyebrows_color2,
		makeup_color1 = makeup_color1,
		makeup_color2 = makeup_color2,
		blush_color = blush_color,
		lipstick_color1 = lipstick_color1,
		lipstick_color2 = lipstick_color2,
		chest_hair_color = chest_hair_color,

		hair_drawable = GetPedDrawableVariation(playerPed, 2),
		hair_texture = GetPedTextureVariation(playerPed, 2),

		ears_drawable = GetPedPropIndex(playerPed, 2),
		ears_texture = GetPedPropTextureIndex(playerPed, 2),

		-- clothing
		mask_drawable = GetPedDrawableVariation(playerPed, 1),
		mask_texture = GetPedTextureVariation(playerPed, 1),
		arms_drawable = GetPedDrawableVariation(playerPed, 3),
		arms_texture = GetPedTextureVariation(playerPed, 3),
		pants_drawable = GetPedDrawableVariation(playerPed, 4),
		pants_texture = GetPedTextureVariation(playerPed, 4),
		bags_drawable = GetPedDrawableVariation(playerPed, 5),
		bags_texture = GetPedTextureVariation(playerPed, 5),
		shoes_drawable = GetPedDrawableVariation(playerPed, 6),
		shoes_texture = GetPedTextureVariation(playerPed, 6),
		chain_drawable = GetPedDrawableVariation(playerPed, 7),
		chain_texture = GetPedTextureVariation(playerPed, 7),
		tshirt_drawable = GetPedDrawableVariation(playerPed, 8),
		tshirt_texture = GetPedTextureVariation(playerPed, 8),
		bproof_drawable = GetPedDrawableVariation(playerPed, 9),
		bproof_texture = GetPedTextureVariation(playerPed, 9),
		decals_drawable = GetPedDrawableVariation(playerPed, 10),
		decals_texture = GetPedTextureVariation(playerPed, 10),
		torso_drawable = GetPedDrawableVariation(playerPed, 11),
		torso_texture = GetPedTextureVariation(playerPed, 11),

		-- props
		helmet_drawable = GetPedPropIndex(playerPed, 0),
		helmet_texture = GetPedPropTextureIndex(playerPed, 0),
		glasses_drawable = GetPedPropIndex(playerPed, 1),
		glasses_texture = GetPedPropTextureIndex(playerPed, 1),
		watches_drawable = GetPedPropIndex(playerPed, 6),
		watches_texture = GetPedPropTextureIndex(playerPed, 6),
		bracelets_drawable = GetPedPropIndex(playerPed, 7),
		bracelets_texture = GetPedPropTextureIndex(playerPed, 7),
	};

	return skin;
end;

module.getValue = function(key)
	return module.getValues()[key];
end;


-- loads the default multiplayer model (male or female)
local loadDefaultModel = function(malePed)
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


-- apply an object of skin and clothes data
--local applySkin = function(skin, clothes)
local applySkin = function(skin)
	local playerPed = PlayerPedId()

	local face_weight = skin.face_weight;
	local skin_weight = skin.skin_weight;
	SetPedHeadBlendData(playerPed, skin.mom, skin.dad, 0, skin.mom, skin.dad, 0, face_weight, skin_weight, 0.0, false);
	--print("setting", skin.mom, skin.dad, face_weight, skin_weight);
	SetPedFaceFeature(playerPed, 0, skin.nose_width)
	SetPedFaceFeature(playerPed, 1, skin.nose_peak)
	SetPedFaceFeature(playerPed, 2, skin.nose_length)
	SetPedFaceFeature(playerPed, 3, skin.nose_curveness)
	SetPedFaceFeature(playerPed, 4, skin.nose_tip)
	SetPedFaceFeature(playerPed, 5, skin.nose_twist)
	SetPedFaceFeature(playerPed, 6, skin.eyebrows_height)
	SetPedFaceFeature(playerPed, 7, skin.eyebrows_depth)
	SetPedFaceFeature(playerPed, 8, skin.cheeks_height)
	SetPedFaceFeature(playerPed, 9, skin.cheeks_width1)
	SetPedFaceFeature(playerPed, 10, skin.cheeks_width2)
	SetPedFaceFeature(playerPed, 11, skin.eye_opening)
	SetPedFaceFeature(playerPed, 12, skin.lip_thickness)
	SetPedFaceFeature(playerPed, 13, skin.jaw_width)
	SetPedFaceFeature(playerPed, 14, skin.jaw_shape)
	SetPedFaceFeature(playerPed, 15, skin.chin_height)
	SetPedFaceFeature(playerPed, 16, skin.chin_length)
	SetPedFaceFeature(playerPed, 17, skin.chin_width)
	SetPedFaceFeature(playerPed, 18, skin.chin_hole)
	SetPedFaceFeature(playerPed, 19, skin.neck_thickness)

	SetPedHeadOverlay(playerPed, 0, skin.blemishes, skin.blemishes_opacity);
	SetPedHeadOverlay(playerPed, 1, skin.beard, skin.beard_opacity);
	SetPedHeadOverlay(playerPed, 2, skin.eyebrows, skin.eyebrows_opacity);
	SetPedHeadOverlay(playerPed, 3, skin.age, skin.age_opacity);
	SetPedHeadOverlay(playerPed, 4, skin.makeup, skin.makeup_opacity);
	SetPedHeadOverlay(playerPed, 5, skin.blush, skin.blush_opacity);
	SetPedHeadOverlay(playerPed, 6, skin.complexion, skin.complexion_opacity);
	SetPedHeadOverlay(playerPed, 7, skin.sun, skin.sun_opacity);
	SetPedHeadOverlay(playerPed, 8, skin.lipstick, skin.lipstick_opacity);
	SetPedHeadOverlay(playerPed, 9, skin.moles, skin.moles_opacity);
	SetPedHeadOverlay(playerPed, 10, skin.chest_hair, skin.chest_hair_opacity);
	
	SetPedHeadOverlayColor(playerPed, 1, 1, skin.beard_color1, skin.beard_color2) -- Beard Color
	SetPedHeadOverlayColor(playerPed, 2, 1, skin.eyebrows_color1, skin.eyebrows_color2) -- Eyebrows Color
	SetPedHeadOverlayColor(playerPed, 4, 2, skin.makeup_color1, skin.makeup_color2) -- Makeup Color
	SetPedHeadOverlayColor(playerPed, 5, 2, skin.blush_color1) -- Blush Color
	SetPedHeadOverlayColor(playerPed, 8, 1, skin.lipstick_color1, skin.lipstick_color2) -- Lipstick Color
	SetPedHeadOverlayColor(playerPed, 10, 1, skin.chest_hair_color1) -- Torso Color

	SetPedHairColor(playerPed, skin.hair_color, skin.hair_highlight_color);
	SetPedEyeColor(playerPed, skin.eye_color);

	SetPedComponentVariation(playerPed, 2, skin.hair_drawable, skin.hair_texture, 2);

	if skin.bodyb_1 == -1 then
		SetPedHeadOverlay(playerPed, 11, 255, skin.body_blemishes_opacity);
	else
		SetPedHeadOverlay(playerPed, 11, skin.body_blemishes, skin.body_blemishes_opacity);
	end

	if skin.bodyb_3 == -1 then
		SetPedHeadOverlay(playerPed, 12, 255, skin.body_blemishes_effect_opacity);
	else
		SetPedHeadOverlay(playerPed, 12, skin.body_blemishes_effect, skin.body_blemishes_effect_opacity);
	end

	if skin.ears_1 == -1 then
		ClearPedProp(playerPed, 2);
	else
		SetPedPropIndex(playerPed, 2, skin.ears_drawable, skin.ears_texture, 2); -- Ears Accessories
	end

	SetPedComponentVariation(playerPed, 1, skin.mask_drawable, skin.mask_texture, 2);
	SetPedComponentVariation(playerPed, 3, skin.arms_drawable, skin.arms_texture, 2);
	SetPedComponentVariation(playerPed, 4, skin.pants_drawable, skin.pants_texture, 2);
	SetPedComponentVariation(playerPed, 5, skin.bags_drawable, skin.bags_texture, 2);
	SetPedComponentVariation(playerPed, 6, skin.shoes_drawable, skin.shoes_texture, 2);
	SetPedComponentVariation(playerPed, 7, skin.chain_drawable, skin.chain_texture, 2);
	SetPedComponentVariation(playerPed, 8, skin.tshirt_drawable, skin.tshirt_texture, 2);
	SetPedComponentVariation(playerPed, 9, skin.bproof_drawable, skin.bproof_texture, 2);
	SetPedComponentVariation(playerPed, 10, skin.decals_drawable, skin.decals_texture, 2);
	SetPedComponentVariation(playerPed, 11, skin.torso_drawable, skin.torso_texture, 2);
	
	if skin["helmet_1"] == -1 then
		ClearPedProp(playerPed, 0)
	else
		SetPedPropIndex(playerPed, 0, skin.helmet_drawable, skin.helmet_texture, 2) -- Helmet
	end

	if skin["glasses_1"] == -1 then
		ClearPedProp(playerPed, 1)
	else
		SetPedPropIndex(playerPed, 1, skin.glasses_drawable, skin.glasses_texture, 2) -- Glasses
	end

	if skin["watches_1"] == -1 then
		ClearPedProp(playerPed, 6)
	else
		SetPedPropIndex(playerPed, 6, skin.watches_drawable, skin.watches_texture, 2) -- Watches
	end

	if skin["bracelets_1"] == -1 then
		ClearPedProp(playerPed, 7)
	else
		SetPedPropIndex(playerPed, 7, skin.bracelets_drawable, skin.bracelets_texture, 2) -- Bracelets
	end
end

-- changes a single key and reloads the skin/clothes if needed
module.setValue = function(key, val)
	logger.debug("skin", "setValue", key, val);
	local skin = module.getValues();
	skin[key] = val;
	module.setValues(skin);
end;

-- loads an object of values and reloads the skin/clothes if needed
module.setValues = function(skin)
	--print("setValues", json.encode(skin));
	if skin.sex then
		if skin.sex == 0 then
			loadDefaultModel(true);
		else
			loadDefaultModel(false);
		end
	end

	applySkin(skin);
end;