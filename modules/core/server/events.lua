local Event = module.Event;

module.onTick = Event:new();

Citizen.CreateThread(function()
    while true do
        module.onTick:Invoke();
        Citizen.Wait(0);
    end
end);