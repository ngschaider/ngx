local callback = M("callback");

module.rpc = function(name, cb, ...)
	callback.trigger("user:rpc", cb, name, ...);
end;