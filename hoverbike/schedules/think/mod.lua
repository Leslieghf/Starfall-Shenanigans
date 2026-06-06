--@include starfall_shenanigans/std/schedules/mod.lua

local StdSchedules = require("starfall_shenanigans/std/schedules/mod.lua")

local ThinkSchedule = StdSchedules.newSchedule("think")

ThinkSchedule.startupDone = false
ThinkSchedule.startupSchedule = nil

function ThinkSchedule.run()
    if not ThinkSchedule.startupDone then
        ThinkSchedule.startupSchedule.run()
        ThinkSchedule.startupDone = true
    end

    return StdSchedules.runSystems(ThinkSchedule)
end

return ThinkSchedule
