local Construct = function(id)
    local self = {};

    self.id = id;

    self.getItemIds = function()
        local results = MySQL.query.await("SELECT id FROM items WHERE inventory_id=?", {self.id});
		
		local ids = {};
		for k,v in pairs(results) do
			table.insert(ids, v.id);
		end
		return ids;
    end;

    self.getItems = function()
        local ids = self.getItemIds();

        local items = {};
        for _,id in pairs(ids) do
            local item = itemClass.getById(id);
            table.insert(items, item);
        end

        return items;
    end;
end;