local event = M("event");

module.showNotification = function(msg)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostTicker(0,1)
end
event.onServer("notification:showNotification", NGX.ShowNotification);

module.showAdvancedNotification = function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry("ngxAdvancedNotification", msg)
	BeginTextCommandThefeedPost("ngxAdvancedNotification")
	if hudColorIndex then ThefeedSetNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end
event.onServer("notification:showAdvancedNotification", NGX.ShowAdvancedNotification);

module.showHelpNotification = function(msg, thisFrame, beep, duration)
	AddTextEntry("ngxHelpNotification", msg)

	if thisFrame then
		DisplayHelpTextThisFrame("ngxHelpNotification", false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp("ngxHelpNotification")
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end
event.onServer("notification:showHelpNotification", module.ShowHelpNotification);

module.showFloatingHelpNotification = function(msg, coords)
	AddTextEntry("ngxFloatingHelpNotification", msg)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp("ngxFloatingHelpNotification")
	EndTextCommandDisplayHelp(2, false, false, -1)
end
event.onServer("notification:showHelpNotification", module.showFloatingHelpNotification);