
function OpenClothesMenu()
	if pool:IsAnyMenuOpen() then
		return;
	end

    pool:Remove();
	
    menu = NativeUI.CreateMenu("Dein Charakter");
    pool:Add(menu);
	
	menu.Controls.Back.Enabled = false;

    ESX.TriggerServerCallback('ngSkin:GetSkin', function(skin)
        if skin.sex == 0 then
            torsoData = Config.MaleTorsoData;
        elseif skin.sex == 1 then
            torsoData = Config.FemaleTorsoData;
        end
    
        local menuItems = {}
        local componentValues = {}
		
        for k, v in pairs(Config.skinContent) do
            componentValues[v.name] = {}
    
            local amountOfComponents
            if v.type == 1 then
                amountOfComponents = GetNumberOfPedDrawableVariations(GetPlayerPed(-1), v.componentID)-1
            elseif v.type == 2 then
                amountOfComponents = GetNumberOfPedPropDrawableVariations(GetPlayerPed(-1), v.componentID)-1
            else
                amountOfComponents = v.amountComponents
            end
            
            if v.name == 'ears_1' or v.name == 'helmet_1' then
                table.insert(componentValues[v.name], -1);
            end
    
            for i2=0, amountOfComponents-1, 1 do
                if v.blockedParts[LastSkin.sex] ~= nil and #v.blockedParts[LastSkin.sex] > 0 then
                    for j2, blockedNumber in pairs(v.blockedParts[LastSkin.sex]) do
                        if i2 == blockedNumber then
                            break
                        elseif j2 == #v.blockedParts[LastSkin.sex] then
                            table.insert(componentValues[v.name], i2)
    
                        end
                    end
                else
                    table.insert(componentValues[v.name], i2)
                end
                
            end
    
            local finalIndex = LastSkin[v.name]
            for findIndexCount, findIndexData in pairs(componentValues[v.name]) do
                if findIndexData == LastSkin[v.name] then
                    finalIndex = findIndexCount
                    break
                end
            end
			
            local newValues = {}
            for i=1, #componentValues[v.name], 1 do
                table.insert(newValues, i)
            end
			
            local Component1ListItem = NativeUI.CreateListItem('~o~→ ~s~' .. v.label, componentValues[v.name], finalIndex)
            menu:AddItem(Component1ListItem)
            table.insert(menuItems, {
                item = Component1ListItem,
                type = 1,
                data = v
			});
    
    
            if v.name2 ~= nil then
                variationValues = {}
                local amountOfVariations;
                if v.type == 1 then
                    amountOfVariations = GetNumberOfPedTextureVariations(GetPlayerPed(-1), v.componentID, LastSkin[v.name]);
                elseif v.type == 2 then
                    amountOfVariations = GetNumberOfPedPropTextureVariations(PlayerPedId(-1), v.componentID, LastSkin[v.name]);
                else 
                    amountOfVariations = v.amountVariations;
                end
				
                for i2 = 0, amountOfVariations, 1 do
                    table.insert(variationValues, i2);
                end
                
                local variationString = "Farbe ändern";
                if v.type == 3 then
                    variationString = "Variante ändern";
                end
                local component2Item = NativeUI.CreateListItem(variationString, variationValues, LastSkin[v.name2]);
                menu:AddItem(component2Item);
    
                menuItems[#menuItems].parent = component2Item;
                table.insert(menuItems, {
                    item = component2Item,
                    type = 2,
                    data = v
				});
            end
			
            menu.OnListChange = function(sender, item, index)
                local selectedIndex = index 
    
                for k2, v2 in pairs(menuItems) do
                    if v2.item == item then
    
                        if v2.type == 1 then
                            if v2.data.name ~= "arms" and v2.data.type ~= 3 then
                              TriggerEvent('skinchanger:change', v2.data.name2, 0)
                            end
                            TriggerEvent('skinchanger:change', v2.data.name, componentValues[v2.data.name][selectedIndex])
    
                            CreateSkinCam()
                            zoomOffset = v2.data.zoomOffset
                            camOffset = v2.data.camOffset
    
                            if v2.parent ~= nil then
                                variationValues = {}
                                local amountOfVariations
                                if v2.data.type == 1 then
                                    amountOfVariations = GetNumberOfPedTextureVariations(GetPlayerPed(-1), v2.data.componentID, componentValues[v2.data.name][selectedIndex])
                                elseif v2.data.type == 2 then
                                    amountOfVariations = GetNumberOfPedPropTextureVariations(PlayerPedId(-1), v2.data.componentID, componentValues[v2.data.name][selectedIndex])
                                else
                                    amountOfVariations = v2.data.amountVariations
                                end
                                for i3=0, amountOfVariations, 1 do
                                    table.insert(variationValues, i3)
                                end
                                v2.parent._Index = 1
                                v2.parent.Items = variationValues
                            end
    
                            if v2.data.componentID == 11 then
                                if torsoData[componentValues[v2.data.name][selectedIndex]] ~= nil then
                                    TriggerEvent('skinchanger:change', 'arms', torsoData[componentValues[v2.data.name][selectedIndex]].arms)
                                    TriggerEvent('skinchanger:change', 'tshirt_2', 0)
                                    TriggerEvent('skinchanger:change', 'tshirt_1', torsoData[componentValues[v2.data.name][selectedIndex]].validShirts[1])
                                end
                            end
                        elseif v2.type == 2 then
                            TriggerEvent('skinchanger:change', v2.data.name2, selectedIndex-1)
                        end
    
                        break;
                    end
                end
    
            end
        end

        local spacerItem = NativeUI.CreateItem('~b~', '~b~');
        menu:AddItem(spacerItem);

        local saveItem = NativeUI.CreateItem("~b~Speichern", '~b~');
        menu:AddItem(saveItem);

        saveItem.Activated = function(sender, item, index)
            menu:Visible(false);
            TriggerEvent('skinchanger:getSkin', function(skin);
                TriggerServerEvent("ngSkin:SaveSkin", skin);
				TriggerEvent("ngCharCreator:CharacterCreated", true);
				TriggerServerEvent("ngCharCreator:CharacterCreated", true);
            end)
            DeleteSkinCam();
        end

        menu:Visible(true);
        pool:RefreshIndex();
        pool:MouseControlsEnabled(false);
        pool:MouseEdgeEnabled(false);
        pool:ControlDisablingEnabled(false);
    end)
end