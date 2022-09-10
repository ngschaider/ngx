local logger = M("core").logger;

module.table = {};

module.table.dump = function(table, nb)
	if nb == nil then
		nb = 0;
	end

	if type(table) == "table" then
		local s = "";
		for i = 1, nb + 1, 1 do
			s = s .. "    ";
		end

		s = "{\n";
		for k,v in pairs(table) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"';
			end
			for i = 1, nb, 1 do
				s = s .. "    ";
			end
			s = s .. "["..k.."] = " .. module.table.dump(v, nb + 1) .. ",\n";
		end

		for i = 1, nb, 1 do
			s = s .. "    ";
		end

		return s .. "}";
	else
		return tostring(table);
	end
end;

-- nil proof alternative to #table
module.table.size = function(t)
	local count = 0;

	for _,_ in pairs(t) do
		count = count + 1;
	end

	return count;
end

module.table.set = function(t)
	local set = {};
	for k,v in ipairs(t) do 
		set[v] = true;
	end
	return set;
end

module.table.indexOf = function(t, value)
	if not t then 
		return -1; 
	end

	for i=1, #t, 1 do
		if t[i] == value then
			return i;
		end
	end

	return -1;
end;

module.table.remove = function(t, value)
	local index = module.table.indexOf(t, value);
	t[index] = nil;
end;

module.table.contains = function(t, value)
	return module.table.indexOf(t, value) ~= -1;
end;

module.table.containsKey = function(t, value)
	for k,v in pairs(t) do
		if k == value then
			return true;
		end
	end
	
	return false;
end;

module.table.lastIndexOf = function(t, value)
	for i=#t, 1, -1 do
		if t[i] == value then
			return i;
		end
	end

	return -1;
end;

module.table.find = function(t, cb)
	--logger.debug("utils->table", "got ", json.encode(t));
	for k,v in pairs(t) do
		if cb(v) then
			logger.debug("utils->table", "returning");
			return v;
		end
	end

	return nil;
end;

module.table.findIndex = function(t, cb)
	for k,v in pairs(t) do
		if cb(v) then
			return k;
		end
	end

	return nil;
end;

module.table.filter = function(t, cb)
	local newTable = {};

	for k,v in pairs(t) do
		if cb(v, k) then
			table.insert(newTable, t[i]);
		end
	end

	return newTable;
end;

module.table.map = function(t, cb)
	local newTable = {};

	for k,v in pairs(t) do
		local newKey, newValue = cb(v, k);
		newTable[newKey] = newValue;
	end

	return newTable;
end;

module.table.mapKeys = function(t, cb)
	return module.table.map(t, function(v, k)
		local newKey = cb(v, k);
		return newKey, v;
	end)
end;

module.table.mapValues = function(t, cb)
	return module.table.map(t, function(v, k)
		local newValue = cb(v, k);
		return k, newValue;
	end);
end;

module.table.reverse = function(t)
	local newTable = {};

	for i=#t, 1, -1 do
		table.insert(newTable, t[i]);
	end

	return newTable;
end;

module.table.clone = function(t)
	if type(t) ~= "table" then
		return t;
	end

	local meta = getmetatable(t);
	local target = {};

	for k,v in pairs(t) do
		if type(v) == "table" then
			target[k] = module.Clone(v);
		else
			target[k] = v;
		end
	end

	setmetatable(target, meta);

	return target
end;

-- create a new table with values of t1 and t2
-- keys are lost in the process
module.table.concat = function(t1, t2)
	local res = {};

	for k,v in pairs(t1) do
		table.insert(res, v);
	end

	for k,v in pairs(t2) do
		table.insert(res, v);
	end

	return res;
end;

module.table.join = function(t, sep)
	local sep = sep or ",";
	local res = "";

	for i=1, #t, 1 do
		if i > 1 then
			res = res .. sep;
		end

		res = res .. t[i];
	end

	return res;
end;

-- Credit: https://stackoverflow.com/a/15706820
-- Description: sort function for pairs
module.table.sort = function(t, order)
	-- collect the keys
	local keys = {};

	for k,_ in pairs(t) do
		keys[#keys + 1] = k;
	end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a,b)
			return order(t, a, b);
		end)
	else
		table.sort(keys);
	end

	-- return the iterator function
	local i = 0;

	return function()
		i = i + 1;
		if keys[i] then
			return keys[i], t[keys[i]];
		end
	end
end;