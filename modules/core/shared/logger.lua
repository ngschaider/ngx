module.logger = {};

local hiddenCategories = {};
module.logger.hideCategory = function(name)
    hiddenCategories[name] = true;
end;
module.logger.showCategory = function(name)
    hiddenCategories[name] = nil;
end;

local log = function(prefix, cat, msg, ...)
    if not hiddenCategories[cat] then
        print(prefix .. "[" .. cat .. "] " .. msg, ...);
    end
end

module.logger.debug = function(cat, msg, ...)
    log("^3[DEBUG]^7", cat, msg, ...);
end;

module.logger.info = function(msg, ...)
    log("^3[INFO]^7", cat, msg, ...);
end;

module.logger.warn = function(msg, ...)
    log("^3[WARNING]^7", cat, msg, ...);
end;

module.logger.error = function(msg, ...)
    log("^3[ERROR]^7", cat, msg, ...);
end;