local event = M("event");
local command = M("command");
local callback = M("callback");

event.on("character:construct:after", function(character)
    character.getSkin = function()
        local skinStr = MySQL.scalar.await("SELECT skin FROM characters WHERE id=?", {character.id});
        return json.decode(skinStr);
    end;
    table.insert(character.rpcWhitelist, "getSkin");

    character.setSkin = function(skin)
        local skinStr = json.encode(skin);
        MySQL.update.await("UPDATE characters SET skin=? WHERE id=?", {skinStr, character.id});
    end;
    table.insert(character.rpcWhitelist, "setSkin");
end);

event.on("character:create:after", function(character)
    local skin = {face_md_weight=50, glasses_1=0, chin_2=0, nose_5=0, eyebrows_4=0, tshirt_2=0, moles_1=0, eyebrows_6=0, tshirt_1=0, shoes_1=0, neck_thickness=0, moles_2=0, chest_3=0, cheeks_2=0, hair_2=0, bags_1=0, chain_1=0, eyebrows_2=0, chin_1=0, shoes_2=0, age_2=0, helmet_2=0, nose_3=0, nose_6=0, lipstick_3=0, bracelets_2=0, cheeks_1=0, torso_1=0, makeup_4=0, decals_1=0, chin_4=0, hair_1=0, sun_2=0, blush_1=0, nose_4=0, skin_md_weight=50, eyebrows_5=0, sex=0, bodyb_4=0, ears_2=0, arms_2=0, bodyb_1=-1, beard_1=0, watches_2=0, beard_4=0, bracelets_1=-1, glasses_2=0, eyebrows_3=0, beard_2=0, lipstick_4=0, bags_2=0, chest_2=0, bodyb_3=-1, mask_1=0, eye_squint=0, ears_1=-1, jaw_1=0, pants_2=0, pants_1=0, bproof_1=0, mask_2=0, torso_2=0, blemishes_2=0, watches_1=-1, eye_color=0, blemishes_1=0, chin_3=0, blush_3=0, complexion_2=0, makeup_3=0, bproof_2=0, complexion_1=0, nose_1=0, lipstick_2=0, nose_2=0, lipstick_1=0, bodyb_2=0, sun_1=0, mom=21, makeup_2=0, chest_1=0, decals_2=0, arms=0, helmet_1=-1, jaw_2=0, hair_color_1=0, eyebrows_1=0, lip_thickness=0, beard_3=0, chain_2=0, cheeks_3=0, hair_color_2=0, blush_2=0, age_1=0, makeup_1=0, dad=0};

    MySQL.update.await("UPDATE characters SET skin=? WHERE id=?", {
        json.encode(skin),
        character.id,
    });
end);

command.registerCommand("getskin", function(user, args)
    callback.trigger("skin:getSkin", user.getPlayerId(), function(skin)
        print(json.encode(skin));
    end);
end, true, {
	help = "Gebe den aktuellen Charakter-Skin in der Konsole aus",
});