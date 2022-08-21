NGX = NGX or {};

NGX.LogError = function(err, loc)
    loc = loc or "<unknown location>";
    print(debug.traceback("^1[error] in ^5" .. loc .. "^7\n\n^5message: ^1" .. err .. "^7\n"));
end;

NGX.EvalFile = function(resource, file, env)
    local code = LoadResourceFile(resource, file);
    if not code then 
        NGX.LogError("could not load resource file @" .. resource .. ":" .. file);
        return;
    end
    local fn, err = load(code, '@' .. resource .. ':' .. file, 't', env);

    if err then
        NGX.LogError(err, '@' .. resource .. ':' .. file);
        return env, false;
    end

    local success = true;

    local status, result = xpcall(fn, function(err)
        success = false;
        NGX.LogError(err, '@' .. resource .. ':' .. file);
    end);

    return env, success;
end;

-- placeholder
_U = function()
    return ""; 
end

local modules = json.decode(LoadResourceFile(GetCurrentResourceName(), "modules.json"));
for k,v in pairs(modules) do
    M(v);
end

--print('[^2INFO^7] ^5NGX^0 initialized with ' .. #modules .. " modules.");