NGX = NGX or {};

local loadedModules = {};
local resourceName = GetCurrentResourceName();

local GetEntryPoints = function(moduleName)
    local sides = {
        "shared",
    };

    if IsDuplicityVersion() then
        table.insert(sides, "server");
    else
        table.insert(sides, "client");
    end

    local entryPoints = {};

    for _,side in pairs(sides) do
        local path = "modules/" .. moduleName .. "/" .. side .. ".lua";
        --print(resourceName, path);
        if LoadResourceFile(resourceName, path) then
            --print("inserting");
            table.insert(entryPoints, path);
        end
    end
    --print(json.encode(entryPoints));

    return entryPoints;
end;

local CreateEnv = function(moduleName)
    local env = {};

    env.run = function(file, _env) 
        return NGX.EvalFile(resourceName, "modules/" .. moduleName .. "/" .. file, _env or env);
    end;

    --[[env.print = function(...)
        local args = {...};

        local str = "^7[^5" .. moduleName .. "^7]";

        for k,v in pairs(args) do
            str = str .. " " .. tostring(v);
        end

        print(str);
    end;]]
    
    env.module = {};

    setmetatable(env, {
        __index = _G
    });

    return env;
end;

NGX.LoadModule = function(moduleName)
    if loadedModules[moduleName] then
        return;
    end

    print("[^2INFO^7] Loading module " .. moduleName);

    local moduleEnv = CreateEnv(moduleName);
    local entryPoints = GetEntryPoints(moduleName);

    local success = true;

    for _,v in pairs(entryPoints) do
        moduleEnv, success = NGX.EvalFile(resourceName, v, moduleEnv);
        if not success then
            break;
        end
    end
    
    if not success then
        error("module [" .. moduleName .. "] does not exist");
    end

    loadedModules[moduleName] = moduleEnv.module;
end


M = function(moduleName)
    return setmetatable({}, {
        __metatable = "<NGX_MODULE_METATABLE_" .. moduleName .. ">",
        __name = moduleName,
        __index = function(obj, key)
            --print("__index called on " .. moduleName);
            if not loadedModules[moduleName] then
                NGX.LoadModule(moduleName);
            end
            return loadedModules[moduleName][key];
        end,
        __newindex = function(obj, key, value)
            if not loadedModules[moduleName] then
                NGX.LoadModule(moduleName);
            end
            loadedModules[moduleName][key] = value;
        end,
        __call = function(obj, ...)
            --print("__call called on " .. moduleName);
            if not loadedModules[moduleName] then
                NGX.LoadModule(moduleName);
            end
            return loadedModules[moduleName](...);
        end,
        --[[__tostring = function(obj)
            if not loadedModules[moduleName] then
                NGX.LoadModule(moduleName);
            end
            loadedModules[moduleName]._tostring();
        end]]
    })
end;