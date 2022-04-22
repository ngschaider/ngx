local userClass = M("userClass");
local task = M("task");

task.setInterval(1000 * 60 * 60, function()
	local users = userClass.GetActive();

	for _, user in pairs(users) do
		local character = user.getCurrentCharacter();

		if character then
			local grade = character.getJobGrade();
			local salary = grade.getSalary();

			local jobAccount = job.getAccount("bank");
			if jobAccount.getValue() >= salary then
				jobAccount.removeValue(salary);

				local characterAccount = character.getAccount("bank");
				characterAccount.addValue(salary);
			end
		end
	end
end);
