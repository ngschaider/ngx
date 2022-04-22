local taskCount = 0;

local runningTasks = {};
module.isTaskRunning = function(id)
    return runningTasks[id] == true;
end;

local GetTaskId = function()
    taskCount = taskCount + 1;
    return taskCount;
end;

module.clearTask = function(id)
    runningTasks[id] = nil;
end;
module.clearTimeout = module.clearTask;
module.clearInterval = module.clearTask;

module.setTimeout = function(msec, cb)
	local id = GetTaskId();

    runningTasks[id] = true;
	Citizen.SetTimeout(msec, function()
		if module.isTaskRunning(id) then
            cb();
            runningTasks[id] = nil;
		end
	end)
end;

module.setInterval = function(msec, cb)
	local id = GetTaskId();

    local run = function()
        module.setTimeout(msec, function()
            if module.isTaskRunning(id) then
                cb();
                run();
            end
        end);
    end;

    run();
    runningTasks[id] = true;
end;