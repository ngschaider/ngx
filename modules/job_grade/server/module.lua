local jobClass = M("job");

local Construct = function(id)
    local self = {};

    self.id = id;

    self.getCharacters = function()
        local results = MySQL.query.await("SELECT character_id FROM character_jobs WHERE job_grade_id=?", {self.id});

        local characters = {};
        for k,v in pairs(results) do
            local character = characterClass.getById(results.character_id);
            table.insert(characters, character);
        end

        return characters;
    end;

    self.getJob = function()
        local id = MySQL.scalar.await("SELECT job_id FROM job_grades where id=?", {self.id});
        if not id then 
            return nil;
        end
        return jobClass.getById(id);
    end;
end;

local jobGrades = {};

module.getById = function(id)
    if not jobGrades[id] then
        jobGrades[id] = Construct(id);
    end

    return jobGrades[id];
end;