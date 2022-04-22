local vehicleClass = M("vehicle");
local jobClass = M("job");

local Construct = function(id)
    local self = {};

    self.id = id;

    self.getVehicleIds = function()
        local res = MySQL.query.await("SELECT id FROM vehicles v WHERE garage_id=?", {self.id});
        local ids = {};
        for k,v in pairs(res) do
            table.insert(ids, v.id);
        end
        return ids;
    end;

    self.getVehicles = function()
        local ids = self.getVehiclesIds();
        local vehicles = {};
        for k,v in pairs(ids) do
            table.insert(vehicles, vehicleClass.getById(v));
        end
        return vehicles;
    end;

    self.getCharacterIds = function()
        local res = MySQL.query.await("SELECT character_id FROM character_garages WHERE garage_id=?", {self.id});
        local ids = {};
        for k,v in pairs(res) do
            table.insert(ids, v.character_id);
        end
        return ids;
    end;

    self.getCharacters = function()
        local ids = self.getCharacterIds();
        local characters = {};
        for k,v in pairs(ids) do
            table.insert(characters, characterClass.getById(v));
        end;
        return characters;
    end;

    self.addCharacter = function(character)
        return MySQL.insert.await("INSERT INTO character_garages (character_id, garage_id) VALUES (?, ?)", {character.id, self.id});
    end;

    self.getJobIds = function()
        local res = MySQL.query.await("SELECT job_id FROM job_garages WHERE garage_id=?", {self.id});
        local ids = {};
        for k,v in pairs(res) do
            table.insert(ids, v.job_id);
        end
        return ids;
    end;

    self.getJobs = function()
        local ids = self.getJobIds();
        local jobs = {};
        for k,v in pairs(jobs) do
            table.insert(jobs, jobClass.getById(v));
        end
        return jobs;
    end;

    self.addJob = function(job)
        return MySQL.insert.await("INSERT INTO job_garages (job_id, garage_id) VALUES (?, ?)", {job.id, self.id});
    end;

end;

local Create = function()

end;

local garages = {};
module.getById = function(id)
    if not garages[id] then
        garages[id] = Construct(id);
    end

    return garages[id];
end;