local command = M("command");

command.registerCommand("tp", function(user, args)
	user.setCoords(args);
end, true, {
	help = "Zu Koordinaten teleportieren", 
	arguments = {
		{name = "x", help = "X-Koordinate", type = "number"},
		{name = "y", help = "Y-Koordinate", type = "number"},
		{name = "z", help = "Z-Koordinate", type = "number"},
	}
});

command.registerCommand("coords", function(user, args)
	user.emit("admin:printCoords");
end, true, {help = "Print the current coordinates in the client console"});

command.registerCommand("setjob", function(user, args)
	args.character.setJob(args.job);
end, true, {
	help = "Setze den Job eines Charakters", 
	arguments = {
		{name = "character", type = "character"},
		{name = "job", type = "job"},
		{name = "grade", type = "grade", args = {
			job = "job",
		}}
	}
});

command.registerCommand("car", function(user, args)
	user.emit("commands:spawnVehicle", args.car);
end, false, {
	help = "Fahrzeug spawnen", 
	arguments = {
		{name = "car", help = "Fahrzeug Model", type = "string"},
	}
});

command.registerCommand("dv", function(user, args)
	user.emit("commands:deleteVehicle");
end, true, {help = "Lösche aktuelles Fahrzeug"});

command.registerCommand("setaccountvalue", function(user, args)
	args.account.setValue(args.value);
end, true, {
	help = "Setzt den Wert eines Kontos", 
	arguments = {
		{name = "account", type = "accont"},
		{name = "value", help = "Wert", type = "number"}
	}
});

command.registerCommand("addaccountvalue", function(user, args)
	args.account.addValue(args.value);
end, true, {
	help = "Setzt den Wert eines Kontos", 
	arguments = {
		{name = "account", type = "accont"},
		{name = "value", help = "Wert", type = "number"}
	}
});

command.registerCommand("clear", function(user, args)
	xPlayer.triggerEvent("chat:clear");
end, false, {
	help = "Chat leeren",
});

command.registerCommand("clearall", function(user, args, showError)
	TriggerClientEvent("chat:clear", -1);
end, true, {
	help = "Chat für alle leeren",
});

command.registerCommand("tpm", function(user, args)
	user.triggerEvent("commands:tpm");
end, true, {
	help = "Zur Kartenmarkierung teleportieren",
});