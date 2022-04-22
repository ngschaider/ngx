local event = M("event");

event.on("user:construct:after", function(user)
    user.hasPermission = function(permissionName)
        return IsPlacerAceAllowed(user.getPlayerId(), permissionName);
    end;
    table.insert(user.rpcWhitelist, "hasPermission");
end);