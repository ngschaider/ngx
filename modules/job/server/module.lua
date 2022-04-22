local event = M("event");
local characterClass = M("character");
local accountClass = M("account");

local jobs = {};

local Construct = function(id)
    local self = {};

    self.id = id;

    self.getLabel = function()
        return MySQL.scalar.await("SELECT label FROM jobs WHERE id=?", {self.id});
    end;

    self.setLabel = function(label)
        MySQL.insert.await("UPDATE jobs SET label=? WHERE id=?", {label, self.id});
    end;

    self.getCharacters = function()
        local query = "SELECT c.id FROM characters c INNER JOIN character_jobs cj ON c.id = cj.character_id WHERE cj.job_id = ?";
        local results = MySQL.query.await(query, {self.id});

        local characters = {};
        for k,v in pairs(results) do
            local character = characterClass.getById(v.id);
            table.insert(characters, character);
        end

        return characters
    end;

    self.getGrades = function()
        local query = "SELECT id FROM job_grades WHERE job_id = ?";
        local results = MySQL.query.await(query, {self.id});

        local grades = {};
        for k,v in pairs(results) do
            local grade = gradeClass.getById(v.id);
            table.insert(grades, grade);
        end;

        return grades;
    end;

    self.getAccounts = function()
        local query = "SELECT account_id FROM job_accounts WHERE job_id = ?";
        local results = MySQL.query.await(query, {self.id});

        local accounts = {};
        for k,v in pairs(results) do
            local account = accountClass.getById(self.id);
            table.insert(accounts, account);
        end

        return accounts;
    end;

    self.getAccount = function(accountType)
        local query = "SELECT account_id FROM job_accounts ja INNER JOIN accounts a ON ja.account_id=a.id WHERE ja.job_id=? AND a.type=?";
        local results = MySQL.query.await(query, {self.id, accountType});
    end;
end;

event.on("character:constructor:after", function(character)
    character.getJobGrade = function()
        local query = "SELECT job_grade_id FROM characters WHERE id=?";
        local id = MySQL.scalar.await(query, {character.id});

        return jobGradeClass.getById(id);
    end;
end);

module.getById = function(id)
    if not jobs[id] then
        jobs[id] = Construct(id);
    end

    return jobs[id];
end;

module.createJob = function(label)
    local id = MySQL.insert.await("INSERT INTO jobs (label) VALUES (?)", {label});
    return module.getById(id);
end;

module.doesExist = function(id)
    local result = MySQL.scalar.await("SELECT 1 FROM jobs WHERE id=?", {id});
    
    if result == 1 then
        return true;
    else
        return false;
    end
end;