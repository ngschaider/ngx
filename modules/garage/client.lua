run("client/class.lua");



local core = M("core");

core.onInit:Add(function()
    -- load the garages to invoke their constructors (which creates markers and notifications)
    ---@diagnostic disable-next-line: unused-local
    local garages = module.GetAll();
end)





