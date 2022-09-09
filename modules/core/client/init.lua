local Event = module.Event;

module.onInit = Event:new();


Citizen.CreateThread(function()
    Citizen.Wait(3000);
    module.onInit:Invoke();
end)

