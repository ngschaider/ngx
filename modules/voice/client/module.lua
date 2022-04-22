local logger = M("logger");

local ranges = {4, 8, 12, 16};
local rangeIndex = 1;

local Connect = function()
    local endpoint = GetCurrentServerEndpoint();
    if not endpoint then
        logger.debug("could not get current endpoint - using localhost");
    end
    local address = endpoint and endpoint:sub(1, -6) or "127.0.0.1";
    local port = 64738;
    logger.debug("connecting to " .. address .. ":" .. port);
    MumbleSetServerAddress(address, port);
end;

RegisterKeyMapping("changevoicerange", "Rededistanz ändern", "KEYBOARD", "N");

RegisterCommand("changevoicerange", function()
    local oldRange = ranges[rangeIndex];

    rangeIndex = rangeIndex + 1;
    if rangeIndex > #ranges then
        rangeIndex = 1;
    end

    local newRange = ranges[rangeIndex];
end);

Citizen.CreateThread(function()
    Connect();

    while true do
        

        Citizen.Wait(0);
    end
end);