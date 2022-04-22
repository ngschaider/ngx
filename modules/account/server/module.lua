local event = M("event");
local characterClass = M("character");
local jobClass = M("job");

local ConstructAccount = function(id)
    local self = {};

    self.id = data.id;

    self.getCharacterIds = function()
        local res = MySQL.query.await("SELECT character_id FROM character_accounts WHERE account_id=?", {self.id});
        local ids = {};
        for k,v in pairs(res) do
            table.insert(ids, res.character_id);
        end
        return ids;
    end;

    self.getCharacters = function()
        local ids = self.getCharacterId();
        local characters = {};
        for k,v in pairs(ids) do
            table.insert(characters, v);
        end
        return characters;
    end;

    self.getJobIds = function()
        local res = MySQL.query.await("SELECT job_id FROM job_accounts WHERE account_id=?", {self.id});
        local ids = {};
        for k,v in pairs(res) do
            table.insert(ids, res.job_id);
        end
        return ids;
    end;

    self.getJobs = function()
        local ids = self.getJobIds();
        local jobs = {};
        for k,v in pairs(ids) do
            table.insert(jobs, jobClass.getById(v));
        end
        return jobs;
    end;

    self.getJobId

    self.getValue = function()
        return MySQL.scalar.await("SELECT value FROM accounts WHERE id=?", {self.id});
    end;

    self.addValue = function(increment)
        MySQL.update.await("UPDATE accounts SET value=value+? WHERE id=?", {increment, self.id});
    end;

    self.removeValue = function(decrement)
        MySQL.update.await("UPDATE accounts SET value=value-? WHERE id=?", {decrement, self.id});
    end;

    self.setValue = function(value)
        MySQL.update.await("UPDATE accounts SET value=? WHERE id=?", {value, self.id});
    end;
end;

event.on("character:construct:after", function(character)
    character.getAccount = function(type)
        local query = "SELECT a.id FROM accounts a INNER JOIN character_accounts ca ON ca.account_id=a.id WHERE ca.character_id=? AND a.type=?";
        local id = MySQL.scalar.await(query, {character.id, type});

        return ConstructAccount(id);
    end;

    character.createAccount = function(type)
        if character.getAccount(type) then
            return false;
        end

        local accountId = MySQL.insert.await("INSERT INTO accounts (type, value) VALUES (?, 0)", {type});

        local query = "INSERT INTO character_accounts (character_id, account_id) VALUES (?, ?)";
        MySQL.insert.await(query, {character.id, accountId});

        return ConstructAccount(character.id);
    end;
end);