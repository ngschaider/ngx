local class = M("class");

local notificationId = 0;
local GetNotificationId = function()
    notificationId = notificationId + 1;
    return notificationId;
end

local helpNotifications = {};

local HelpNotification = class("HelpNotification");

function HelpNotification:initialize(text)
    self.id = GetNotificationId();
    self:setText(text);

    self.visible = false;

    table.insert(helpNotifications, self);
end

function HelpNotification:setText(text)
    AddTextEntry("ngx_helpNotification_" .. self.id, text);
end

function HelpNotification:draw()
    DisplayHelpTextThisFrame("ngx_helpNotification_" .. self.id);
end


Citizen.CreateThread(function()
    while true do
        for _,helpNotification in pairs(helpNotifications) do
            if helpNotification.visible then
                helpNotification:draw();
            end
        end
        Citizen.Wait(0);
    end
end)

module.notification = module.notification or {};
module.notification.CreateHelpNotification = function(...)
    return HelpNotification:new(...);
end