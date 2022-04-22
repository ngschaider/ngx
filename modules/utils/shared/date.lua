module.date = {};


-- thanks to Bart Kiers
-- https://stackoverflow.com/questions/12542853/how-to-validate-if-a-string-is-a-valid-date-or-not-in-lua
module.date.isValid = function(str)
    -- perhaps some sanity checks to see if `str` really is a date
    local d, m, y = str:match("(%d+).(%d+).(%d+)")

    d, m, y = tonumber(d), tonumber(m), tonumber(y);

    if not d or not m or not y then
        return false;
    end

    if d < 0 or d > 31 or m < 0 or m > 12 or y < 0 then
        -- Cases that don't make sense
        return false
    elseif m == 4 or m == 6 or m == 9 or m == 11 then 
        -- Apr, Jun, Sep, Nov can have at most 30 days
        return d <= 30
    elseif m == 2 then
        -- Feb
        if y%400 == 0 or (y%100 ~= 0 and y%4 == 0) then
            -- if leap year, days can be at most 29
            return d <= 29
        else
            -- else 28 days is the max
            return d <= 28
        end
    else 
        -- all other months can have at most 31 days
        return d <= 31
    end
end
