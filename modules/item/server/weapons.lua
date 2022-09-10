local utils = M("utils");

local RegisterWeapon = function(name, label)
    module.Register({
        name = name,
        label = label,
        isUsable = false,
        isDroppable = true,
        onDrop = function(item)
            
        end,
        onCharacterSpawned = function(character)
            local user = character:getUser();
            local playerId = user:getPlayerId();
            local ped = GetPlayerPed(playerId);
            RemoveWeaponFromPed(ped, "weapon_" .. name);

            local inventory = character:getInventory();
            local items = inventory:getItems();

            local filteredItems = utils.table.filter(items, function(item)
                return item.name == name;
            end);

            if #filteredItems > 0 then
                local item = filteredItems[1];

                local ammoCount = item:getItemData().ammoCount;
                GiveWeaponToPed(ped, "weapon_" .. name, ammoCount, false, false);
            end
        end,
    });
end