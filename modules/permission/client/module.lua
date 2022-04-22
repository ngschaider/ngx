local event = M("event");
local callback = M("callback");
local user = M("user");

user.hasPermission = function(permission, cb)
    user.rpc("hasPermission", cb, permission);
end;