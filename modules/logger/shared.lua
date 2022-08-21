module.debug = function(msg, ...)
    print("^3[DEBUG]^7 " .. msg, ...);
end;

module.info = function(msg, ...)
    print("^3[INFO]^7 " .. msg, ...);
end;

module.warn = function(msg, ...)
    print("^3[WARNING]^7 " .. msg, ...);
end;

module.error = function(msg, ...)
    print("^3[ERROR]^7 " .. msg, ...);
end;

