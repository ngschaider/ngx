local Event = module.event;


module.onTick = Event:new();

Citizen.CreateThread(function()
    while true do
        onTick:Invoke();
        Citizen.Wait(0);
    end
end);