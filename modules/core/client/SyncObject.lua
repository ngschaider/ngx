--[[

Refer to the server-side docs for SyncObject. It is mostly used the same way, except:

- syncProperty and rpcMethod do not exist

- call rpc's using character:rpc(args), where character is a SyncObject and args are optional arguments. 
    Multiple arguments are supported

]]


local net = module.net;
local callback = module.callback;
local logger = module.logger;
local class = M("class");
local utils = M("utils");

local cache = {};

local SyncObject = class("SyncObject");

function SyncObject:initialize(type, id, tableName)
    logger.debug("core->SyncObject", "SyncObject:initialize", "type,id,tableName", type, id, tableName);
    self.type = type;
    self.id = id;
    self.table = tableName;
    self._deleted = false;
    self._data = callback.trigger("core:SyncObject:getObjectData", type, id);

    table.insert(cache, self);
end

function SyncObject:getData(key)
    if self._deleted then
        logger.error("core->SyncObject", "SyncObject:getData", "accessing deleted SyncObject: type,id", self.type, self.id);
        return;
    end
    logger.debug("core->SyncObject", "SyncObject:getData", "key", key);
    local value = self._data[key];
    logger.debug("core->SyncObject", "SyncObject:getData", "value", value);
    return value;
end

function SyncObject:setData(key, value)
    if self._deleted then
        logger.error("core->SyncObject", "SyncObject:setData", "accessing deleted SyncObject: type,id", self.type, self.id);
        return;
    end
    self._data[key] = value;
    net.send("core:SyncObject:setProperty", self.type, self.id, key, value);
end

function SyncObject:rpc(name, ...)
    if self._deleted then
        logger.error("core->SyncObject", "SyncObject:rpc", "accessing deleted SyncObject: type,id", self.type, self.id);
        return;
    end
    return callback.trigger("core:SyncObject:rpc", self.type, self.id, name, ...);
end

net.on("core:SyncObject:setProperty", function(type, id, key, value)
    logger.debug("core->SyncObject", "core:SyncObject:setProperty", "type,id,key,value", type, id, key, value);
    local obj = module.GetSyncObject(type, id);
    obj._data[key] = value;
end);

net.on("core:SyncObject:delete", function(type, id)
    if not cache[type .. id] then
        return;
    end

    local obj = module.GetSyncObject(type, id);
    cache[type .. id] = nil;
    obj._deleted = true;
end);

module.SyncObject = SyncObject;

local syncClasses = {};
module.RegisterSyncClass = function(objectClass)
    syncClasses[objectClass.name] = objectClass;
end;

module.GetSyncObject = function(type, id, ...)
    logger.debug("core->SyncObject", "module.GetSyncObject", "type,id", type, id);
    if not cache[type .. id] then
        logger.debug("core->SyncObject", "syncClasses", json.encode(utils.table.map(syncClasses, function(v, k) return k, k; end)));
        logger.debug("core->SyncObject", "module.GetSyncObject", "#syncClasses", utils.table.size(syncClasses));
        cache[type .. id] = syncClasses[type]:new(id, ...);
    end

    return cache[type .. id];
end