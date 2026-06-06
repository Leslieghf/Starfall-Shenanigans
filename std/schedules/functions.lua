local ScheduleFunctions = {}

function ScheduleFunctions.registerSystem(schedule, systemName, run)
    table.insert(schedule.systems, {
        name = systemName,
        run = run
    })
end

function ScheduleFunctions.runSystems(schedule, ...)
    for _, system in ipairs(schedule.systems) do
        if system.run(...) == false then
            return false
        end
    end
end

return ScheduleFunctions
