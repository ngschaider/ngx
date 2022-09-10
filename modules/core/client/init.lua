local Event = module.Event;

module.onInit = Event:new();


Citizen.CreateThread(function()
    Citizen.Wait(200);
    module.onInit:Invoke();
end)

