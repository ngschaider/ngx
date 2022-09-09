local class = M("class")

local Event = class("Event");

function Event:initialize()
    self.listeners = {};
end

function Event:Add(cb)
    table.insert(self.listeners, cb);
end

function Event:Invoke(...)
    for _,cb in pairs(self.listeners) do
        cb(...);
    end
end

module.event = Event;