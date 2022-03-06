NGX = NGX or {};
NGX.Modules = NGX.Modules or {};
NGX.Modules.LoadedModules = {};

local resourceName = GetCurrentResourceName();

local GetEntryPoints = function(moduleName)
    local sides = {
        "shared",
    }

    if IsDuplicityVersion() then
        table.insert(sides, "server");
    else
        table.insert(sides, "client");
    end

    local entryPoints = {};

    for k,v in pairs(sides) do
        local path = 'modules/' .. moduleName .. '/' .. v .. '/module.lua';
        if LoadResourceFile(resourceName, path) then
            table.insert(entryPoints, path);
        end
    end

    return entryPoints;
end;

local CreateModuleEnv = function(moduleName)
    local env = {};

    env.run = function(file, _env) 
        return ESX.EvalFile(resourceName, "modules/" .. moduleName .. "/" .. file, _env or env);
    end;

    env.print = function(...)
        local args = {...};

        local str = "^7/^5" .. moduleName .. "^7]";

        for k,v in pairs(args) do
            str = str .. " " .. tostring(v);
        end

        print(str);
    end;
    
    env.module = {};

    --setmetatable(env, {__index = _G, __newindex = _G});

    return env;
end;

local LoadModule = function(moduleName)
    if NGX.Modules.LoadedModules[moduleName] then
        return NGX.Modules.LoadedModules[moduleName];
    end

    local moduleEnv = CreateModuleEnv(moduleName);
    local entryPoints = GetEntryPoints(moduleName);

    local success = true;
    for k,v in pairs(entryPoints) do
        moduleEnv, success = NGX.EvalFile(resourceName, v, moduleEnv);
        if not success then 
            break;
        end
    end

    if success then
        NGX.Modules.LoadedModules[moduleName] = moduleEnv;
        return moduleEnv;
    else
        NGX.Logger.Error('module [' .. moduleName .. '] does not exist', '@' .. resourceName .. ':boot/sh_modules.lua');
    end

    return 
end;

M = LoadModule;