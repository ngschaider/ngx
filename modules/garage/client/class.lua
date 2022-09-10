local class = M("class");
local logger = M("core").logger;
local utils = M("utils");
local core = M("core");
local Marker = M("marker");
local UI = M("UI");
local Vehicle = M("vehicle");

local Garage = class("Garage", core.SyncObject);
core.RegisterSyncClass(Garage);

function Garage:initialize(id)
    core.SyncObject.initialize(self, "Garage", id, "garages");

    self.takeOutNotification = core.notification.CreateHelpNotification("Drücke ~INPUT_CONTEXT~ um auf die Garage zuzugreifen");
    self.putInNotification = core.notification.CreateHelpNotification("Drücke ~INPUT_CONTEXT~ um dein Fahrzeug einzuparken");

    self.marker = Marker.Create(self:getPosition());
    self.marker.scale = vector3(3.0, 3.0, 0.2);
    self.marker.onEnter:Add(function(data)
        if data.playerVehicle then
            print("1");
            local netId = NetworkGetNetworkIdFromEntity(data.playerVehicle);
            print("2");
            local vehicle = Vehicle.GetByNetId(netId);
            print("3");

            if vehicle then
                print("4");
                self.putInNotification.visible = true;
            end
            print("5");
        else
            self.takeOutNotification.visible = true;
        end
    end);
    self.marker.onExit:Add(function()
        self.putInNotification.visible = false;
        self.takeOutNotification.visible = false;
    end);

    core.onTick:Add(function(data)
        if self.marker.isPlayerInside and IsControlJustPressed(0, 51) then
            if data.playerVehicle then
                local netId = NetworkGetNetworkIdFromEntity(data.playerVehicle);
                local vehicle = Vehicle.GetByNetId(netId);

                if vehicle then
                    vehicle:despawn();
                    vehicle:setGarageId(self.id);
                end
            else
                self:openMenu();
            end
        end
    end)
end

function Garage:openMenu()
    local menu = UI.CreateMenu("Garage " .. self:getName());

    local vehicles = self:getVehicles();
    for _,vehicle in pairs(vehicles) do
        local item = UI.CreateItem(vehicle:getName());
        menu:AddItem(item);

        item.Activated = function()
            menu:Visible(false);
            vehicle:spawn();
            vehicle:setGarageId(nil);

            local veh = NetworkGetEntityFromNetworkId(vehicle:getNetId());
            SetPedIntoVehicle(PlayerPedId(), veh);
        end
    end

    menu:Visible(true);
end

function Garage:getName()
    return self:getData("name");
end

function Garage:getVehicleIds()
    return self:rpc("getVehicleIds");
end

function Garage:getPosition()
    return vector3(
        tonumber(self:getData("positionX")),
        tonumber(self:getData("positionY")),
        tonumber(self:getData("positionZ"))
    );
end

function Garage:getVehicles()
    local ids = self:getVehicleIds();
    local vehicles = utils.table.mapValues(ids, function(id)
        return Vehicle.GetById(id);
    end);
    return vehicles;
end

module.GetById = function(id)
    return core.GetSyncObject("Garage", id);
end

module.GetAll = function()
    logger.debug("garage->class", "module.GetAll");
	local p = promise.new();
	core.callback.trigger("garage:getAllIds", function(ids)
		p:resolve(ids);
	end);
    logger.debug("garage->class", "module.GetAll", "resolving");
	local ids = Citizen.Await(p);

    logger.debug("garage->class", "module.GetAll", "iterating");
	local garages = {};
	for _,id in pairs(ids) do
		local garage = module.GetById(id);
		table.insert(garages, garage);
	end

	return garages;
end;