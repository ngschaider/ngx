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

    for k,side in pairs(sides) do
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

M = function(moduleName)
    if loadedModules[moduleName] then
        return loadedModules[moduleName];
    end

    print("[^2INFO^7] Loading module " .. moduleName);

    local moduleEnv = CreateEnv(moduleName);
    local entryPoints = GetEntryPoints(moduleName);

    local success = true;
    for k,v in pairs(entryPoints) do
        moduleEnv, success = NGX.EvalFile(resourceName, v, moduleEnv);
        if not success then
            break;
        end
    end

    if success then
        loadedModules[moduleName] = moduleEnv.module;
        return loadedModules[moduleName];
    else
        NGX.LogError('module [' .. moduleName .. '] does not exist', '@' .. resourceName .. ':boot/sh_modules.lua');
    end

    return nil;
end;