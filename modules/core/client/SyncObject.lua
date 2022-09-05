--[[

Refer to the server-side docs for SyncObject. It is mostly used the same way, except:

- syncProperty and rpcMethod do not exist

- call rpc's using character:rpc(args), where character is a SyncObject and args are optional arguments. 
    Multiple arguments are supported

]]


local event = module.event;
local class = M("class");
local callback = M("callback");
local logger = M("logger");

local cache = {};

local SyncObject = class("SyncObject");

function SyncObject:initialize(type, id, tableName)
    logger.debug("SyncObject:initialize", "type,id,tableName", type, id, tableName);
    self.type = type;
    self.id = id;
    self.table = tableName;

    local p = promise.new();
    callback.trigger("core:SyncObject:getObjectData", function(data)
        p:resolve(data);
    end, type, id);
    self._data = Citizen.Await(p);

    table.insert(cache, self);
end

function SyncObject:getData(key)
    logger.debug("SyncObject:getData", "key", key);
    local value = self._data[key];
    logger.debug("SyncObject:getData", "value", value);
    return value;
end

function SyncObject:setData(key, value)
    event.emitServer("core:SyncObject:setProperty", self.type, self.id, key, value);
end

function SyncObject:rpc(name, ...)
    local p = promise.new();
    callback.trigger("core:SyncObject:rpc", function(...)
        p:resolve(...);
    end, self.type, self.id, name, ...);
    return Citizen.Await(p);
end

event.onServer("core:SyncObject:setProperty", function(type, id, key, value)
    logger.debug("core:SyncObject:setProperty", "type,id,key,value", type, id, key, value);
    local obj = module.GetSyncObject(type, id);
    obj._data[key] = value;
end);

module.SyncObject = SyncObject;

local syncClasses = {};
module.RegisterSyncClass = function(objectClass)
    syncClasses[objectClass.name] = objectClass;
end;

module.GetSyncObject = function(type, id, ...)
    if not cache[type .. id] then
        cache[type .. id] = syncClasses[type]:new(id, ...);
    end

    return cache[type .. id];
end