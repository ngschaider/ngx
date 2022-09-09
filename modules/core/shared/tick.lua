local Event = module.event;


module.tick = Event:new();

Citizen.CreateThread(function()
    while true do
        tick:Invoke();
        Citizen.Wait(0);
    end
end);