--[[

SyncObjects are the primary and recommended way of synchronizing data between client/server/database.
Each type of SyncObject corresponds to a table in the db.
Each SyncObject represents a db row.

To create a new type of SyncObject create a class which inherits from SyncObject,
register the class as a SyncObject using core.RegisterSyncClass,
call the parent constructor in the initialize function, 
define defaults for variables which are not present in the db,
call self:syncProperty and self:rpcMethod to define what clients are allowed to do.

DO NOT CONSTRUCT SYNCOBJECTS YOURSELF. 
This would circumvent SyncObject's great caching capabilities and increase the amount of queries.
Also, it is not tested, not supported and definiely not recommended.

Instead of constructing SyncObjects yourself use core.GetSyncObject


Example:


local Character = class("Character", core.SyncObject);
core.RegisterSyncClass(Character);

function Character:initialize(id)
	logger.debug("Character:initialize", "id", id);
	core.SyncObject.initialize(self, "Character", id, "characters");

	self:syncProperty("id", true, false);
	self:syncProperty("userId", true, false);
	self:syncProperty("firstname", true, false);
	self:syncProperty("lastname", true, false);
	self:rpcMethod("getSkin", true);
	self:rpcMethod("setSkin", true);
end

-- this is a pure utility function to wrap around SyncObject's getData method
function Character:getId()
	return self:getData("id");
end


For getting a SyncObject (for example, get the Character with ID 2):
local character = core.GetSyncObject("Character", 2);
]]

local event = module.event;
local callback = module.callback;
local logger = module.logger;
local class = M("class");
local utils = M("utils");

--[[
    holds all constructed syncObjects. The key of this table is composed by concatenating the type with the object's id like
    local key = obj.type .. obj.id;
]]
local cache = {};

local SyncObject = class("SyncObject");

--[[
    Returns true if the client can read the specified key on the specified type, false otherwise.
]]
SyncObject.static.canClientRead = function (type, key)
    logger.debug("SyncObject->canClientRead", "type", type);
    logger.debug("SyncObject->canClientRead", "key", key);
    return SyncObject._sync[type] and SyncObject._sync[type].properties[key] and SyncObject._sync[type].properties[key].read;
end

--[[
    Returns true if the client can write to the specified key on the specified type, false otherwise.
]]
SyncObject.static.canClientWrite = function (type, key)
    return SyncObject._sync[type] and SyncObject._sync[type].properties[key] and SyncObject._sync[type].properties[key].write;
end

--[[
    This is purely internal and is used to remember which properties should be read-only, read-write or completely hidden.
    This also holds all the names of rpc's which clients are allowed to call
]]
SyncObject.static._sync = {
    properties = {},
    rpcs = {},
};


--[[
    Initialize the SyncObject
    This also also gets the data from the DB and saves it in the _data property
    It also saves the column names in the columns property to later know which values should be saved in the db
]]
function SyncObject:initialize(type, id, tableName)
    logger.debug("SyncObject:initialize", "type,id,tableName", type, id, tableName);
    self.type = type;
    self.id = id;
    self.table = tableName;
    self._data = MySQL.single.await("SELECT * FROM `" .. tableName .. "` WHERE id=?", {id});
    self.columns = utils.table.map(self._data, function()
        return true;
    end);

    table.insert(cache, self);
end

--[[
    returns the value from the _data property with the given key.
]]
function SyncObject:getData(key)
    local value = self._data[key];
    logger.debug("SyncObject:getData", "type,id,key,value", self.type, self.id, key, value);
    return value;
end

--[[
    sets the given value in the _data property by the given key.
]]
function SyncObject:setData(key, value)
    logger.debug("SyncObject:setData", "type,id,key,value", self.type, self.id, key, value);
    if SyncObject.canClientRead(self.type, key) then
        event.emitClient("core:SyncObject:setProperty", -1, self.type, self.id, key, value);
    end
    if self.columns[key] then
        MySQL.update.await("UPDATE `" .. self.table .. "` SET `" .. key .. "`=?", {value});
    end
    self._data[key] = value;
end

--[[
    if read is true sets the given key to be readable by the client, otherwise the client can't read from the given key.
    if write is true sets the given key to be writable by the client, otherwise the client can't write to the given key.
]]
function SyncObject:syncProperty(key, read, write)
    logger.debug("SyncObject:syncProperty", "key", key);
    if not SyncObject._sync[self.type] then
        SyncObject._sync[self.type] = {
            properties = {},
            rpcs = {},
        };
    end
    
    logger.debug("syncProperty", "self.type,key,read,write", self.type, key, read, write);
    SyncObject._sync[self.type].properties[key] = {
        read = read,
        write = write,
    };

    logger.debug("SyncObject:syncProperty", "SyncObject._sync", json.encode(SyncObject._sync));
end


--[[
    if toggle is true sets the given method name to be callable by the client, otherwise the client can't call the given method.
]]
function SyncObject:rpcMethod(name, toggle)
    if not SyncObject._sync[self.type] then
        SyncObject._sync[self.type] = {
            properties = {},
            rpcs = {},
        };
    end

    SyncObject._sync[self.type].rpcs[name] = toggle or true;
end

module.SyncObject = SyncObject;

--[[
    holds all registered sync classes so we can later look up the name and therefore it's type
]]
local syncClasses = {};
module.RegisterSyncClass = function(objectClass)
    syncClasses[objectClass.name] = objectClass;
end

module.GetSyncObject = function(type, id, ...)
    if not cache[type .. id] then
        logger.debug("creating new SyncObject", "type,id", type, id);
        cache[type .. id] = syncClasses[type]:new(id, ...);
    end

    return cache[type .. id];
end;

callback.register("core:SyncObject:rpc", function(playerId, cb, type, id, name, ...)
    local obj = module.GetSyncObject(type, id);

    if not obj then
        logger.debug("SyncObject not found", type, id);
        return;
    end

    logger.debug("core:SyncObject:rpc", "type,name", type, name)
    if not SyncObject._sync[type] or not SyncObject._sync[type].rpcs[name] then
        logger.debug("SyncObject rpc not allowed", type, id, name);
        return;
    end

    local ret = obj[name](obj, name, ...);
    cb(ret);
end)

event.onClient("core:SyncObject:setProperty", function(playerId, type, id, key, value)
    logger.debug("core:SyncObject:setProperty", "type,id,key,value", type, id, key, value);
    local obj = module.GetSyncObject(type, id);

    if not obj then
        logger.debug("SyncObject not found", type, id);
        return;
    end

    if SyncObject.canClientWrite(type, key) then
        obj:setData(key, value);
    end
end)

callback.register("core:SyncObject:getObjectData", function(playerId, cb, type, id)
    logger.debug("core:SyncObject:getObjectData", "type,id", type, id);
    local obj = module.GetSyncObject(type, id);

    if not obj then
        logger.debug("SyncObject not found", type, id);
        cb(nil);
        return nil;
    end

    local data = {};
    for k,v in pairs(obj._data) do
        logger.debug("core:SyncObject:getObjectData", "k,v", k, json.encode(v));
        if SyncObject.canClientRead(type, k) then
            data[k] = v;
        end
    end

    logger.debug("core:SyncObject:getObjectData", json.encode(data));
    cb(data);
end)