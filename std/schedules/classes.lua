local ScheduleClasses = {}

function ScheduleClasses.newSchedule(name, run)
    return {
        name = name,
        systems = {},
        run = run
    }
end

return ScheduleClasses
