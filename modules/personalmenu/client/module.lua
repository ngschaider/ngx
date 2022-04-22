local callback = M("callback");
local command = M("command");
local streaming = M("streaming");
local user = M("user");
local skin = M("skin");

local pool = NativeUI.CreatePool();

local clothingOptions = {
	torso = "T-Shirt",
	pants = "Hose",
	shoes = "Schuhe",
	bag = "Tasche",
	bproof = "Jacke"
};

local accessoriesOptions = {
	ears = "Ohren",
	glasses = "Brille",
	helmet = "Helm",
	mask = "Maske",
};

local licensesOptions = {
	identity = "Personalausweis",
	drive = "Führerschein",
	weapon = "Waffenschein",
};

RegisterCommand("personalmenu", function()
	local menu = NativeUI.CreateMenu("Persönliches", "");
	pool:Add(menu);
	
	local nameItem = NativeUI.CreateItem(user.getName());
	menu:AddItem(nameItem);

	local walletMenu = pool:AddSubMenu(menu, "Brieftasche");
	for k,v in pairs(licensesOptions) do
		local viewItem = NativeUI.CreateItem(v .. " anschauen");
		walletMenu:AddItem(viewItem);
		viewItem.Activated = function()
			ViewLicense(k);
		end;
		
		local showItem = NativeUI.CreateItem(v .. " zeigen");
		walletMenu:AddItem(showItem);
		showItem.Activated = function()
			ShowLicense(k);
		end;
	end

	local clothingMenu = pool:AddSubMenu(menu, "Kleidung");
	local clothingMenuLookup = {};
	for k,v in pairs(clothingOptions) do
		local item = NativeUI.CreateItem(v);
		clothingMenu:AddItem(item);

		item.Activated = function()
			ToggleClothing(k);
		end;
	end
		
	local accessoriesMenu = pool:AddSubMenu(menu, "Accessories");
	local accessoriesMenuLookup = {};
	for k,v in pairs(accessoriesOptions) do
		local item = NativeUI.CreateItem(v);
		accessoriesMenu:AddItem(item);

		item.Activated = function()
			ToggleAccessory(k);
		end;
	end
		
	local outfitOptions = {};
	local outfitsProcessed = 0;
	for k,v in pairs(Config.Outfits) do
		if callback.trigger("permission:hasPermission", function(hasPermission)
			outfitsProcessed = outfitsProcessed + 1;
			if hasPermission then
				table.insert(outfitOptions, v);
			end
		end, "personalmenu.outfit." .. v.name);
	end

	while outfitsProcessed < #Config.Outfits then
		Citizen.Wait(0);
	end

	if #outfitOptions > 0 then
		local adminMenu = pool:AddSubMenu(menu, "Team");
		
		for k,v in pairs(outfitOptions) do
			local item = NativeUI.CreateItem(v.label);
			adminMenu:AddItem(item);

			item.Activated = function()
				SetOutfit(v);
			end;
		end
		
		resetOutfit = NativeUI.CreateItem("Outfit zurücksetzen");
		adminMenu:AddItem(item);
		
		resetOutfit.Activated = function()
			ResetOutfit();
		end;
	end	
	
	menu:Visible(true);
	pool:RefreshIndex();
	pool:MouseEdgeEnabled(false);
end);

RegisterKeyMapping("personalmenu", "Persönliches Menü öffnen", "KEYBOARD", "F5");

Citizen.CreateThread(function()
	while true do
		pool:ProcessMenus();
		Citizen.Wait(0);
	end
end);

local SetOutfit = function(outfit)
	skin.loadDefaultModel(true);
	skin.loadSkin(outfit.values);
end

local ToggleAccessory = function(accessory)
	callback.trigger('esx_accessories:get', function(hasAccessory, accessorySkin)
		if hasAccessory then
			skin.getSKin(function(currentSkin)
				local mAccessory = -1;
				local mColor = 0;

				if accessory == 'ears' then
					startAnimAction('mini@ears_defenders', 'takeoff_earsdefenders_idle')
					Citizen.Wait(250)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif accessory == 'glasses' then
					mAccessory = 0
					startAnimAction('clothingspecs', 'try_glasses_positive_a')
					Citizen.Wait(1000)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif accessory == 'helmet' then
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(1000)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				elseif accessory == 'mask' then
					mAccessory = 0
					startAnimAction('missfbi4', 'takeoff_mask')
					Citizen.Wait(850)
					Player.handsup, Player.pointing = false, false
					ClearPedTasks(plyPed)
				end

				if currentSkin[accessory .. '_1'] == mAccessory then
					mAccessory = accessorySkin[accessory .. '_1']
					mColor = accessorySkin[accessory .. '_2']
				end

				local accessorySkin = {}
				accessorySkin[accessory .. '_1'] = mAccessory
				accessorySkin[accessory .. '_2'] = mColor
				skin.loadClothes(currentSkin, accessorySkin);
			end)
		else
			if accessory == 'ears' then
				notification.showNotification("Du hast keine Ohren");
			elseif accessory == 'glasses' then
				notification.showNotification("Du hast keine Brille");
			elseif accessory == 'helmet' then
				notification.showNotification("Du hast keinen Helm");
			elseif accessory == 'mask' then
				notification.showNotification("Du hast keine Maske");
			end
		end
	end, accessory);
end

local ToggleClothing = function(clothing)
	user.getCurrentCharacter().getSkin(function(cSkin)
		skin.getSkin(function(skina)
			if clothing == 'torso' then
				startAnimAction('clothingtie', 'try_tie_neutral_a')
				Citizen.Wait(1000)
				Player.handsup, Player.pointing = false, false
				ClearPedTasks(plyPed)

				if currentSkin.torso_1 ~= skina.torso_1 then
					skin.loadClothes(skina, {
						torso_1 = cSkin.torso_1, 
						torso_2 = cSkin.torso_2, 
						tshirt_1 = cSkin.tshirt_1, 
						tshirt_2 = cSkin.tshirt_2, 
						arms = cSkin.arms
					});
				else
					skin.loadClothes(skina, {
						torso_1 = 15, 
						torso_2 = 0, 
						tshirt_1 = 15, 
						tshirt_2 = 0, 
						arms = 15
					});
				end
			elseif clothing == 'pants' then
				if skin.pants_1 ~= skina.pants_1 then
					skin.loadClothes(skina, {
						pants_1 = skin.pants_1, 
						pants_2 = skin.pants_2
					})
				else
					if skin.sex == 0 then
						skin.loadClothes(skina, {
							pants_1 = 61, 
							pants_2 = 1
						});
					else
						skin.loadClothes(skina, {
							pants_1 = 15, 
							pants_2 = 0
						});
					end
				end
			elseif clothing == 'shoes' then
				if skin.shoes_1 ~= skina.shoes_1 then
					skin.loadClothes(skina, {
						shoes_1 = skin.shoes_1, 
						shoes_2 = skin.shoes_2
					});
				else
					if skin.sex == 0 then
						skin.loadClothes(skina, {
							shoes_1 = 34, 
							shoes_2 = 0
						});
					else
						skin.loadClothes(skina, {
							shoes_1 = 35, 
							shoes_2 = 0
						});
					end
				end
			elseif clothing == 'bag' then
				if skin.bags_1 ~= skina.bags_1 then
					skin.loadClothes(skina, {
						bags_1 = skin.bags_1, 
						bags_2 = skin.bags_2
					});
				else
					skin.loadClothes(skina, {
						bags_1 = 0, 
						bags_2 = 0
					});
				end
			elseif clothing == 'bproof' then
				startAnimAction('clothingtie', 'try_tie_neutral_a')
				Citizen.Wait(1000)
				Player.handsup, Player.pointing = false, false
				ClearPedTasks(plyPed)

				if skin.bproof_1 ~= skina.bproof_1 then
					skin.loadClothes(skina, {
						bproof_1 = skin.bproof_1, 
						bproof_2 = skin.bproof_2
					});
				else
					skin.loadClothes(skina, {
						bproof_1 = 0, 
						bproof_2 = 0
					});
				end
			end
		end)
	end)
end

local startAnimAction = function(lib, anim)
	streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, 1.0, -1, 49, 0, false, false, false);
		RemoveAnimDict(lib);
	end);
end;