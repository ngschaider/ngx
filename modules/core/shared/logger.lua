module.logger = {};

module.logger.debug = function(msg, ...)
    print("^3[DEBUG]^7 " .. msg, ...);
end;

module.logger.info = function(msg, ...)
    print("^3[INFO]^7 " .. msg, ...);
end;

module.logger.warn = function(msg, ...)
    print("^3[WARNING]^7 " .. msg, ...);
end;

module.logger.error = function(msg, ...)
    print("^3[ERROR]^7 " .. msg, ...);
end;