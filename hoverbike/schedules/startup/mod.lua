--@include starfall_shenanigans/std/schedules/mod.lua

local StdSchedules = require("starfall_shenanigans/std/schedules/mod.lua")

local StartupSchedule = StdSchedules.newSchedule("startup")

function StartupSchedule.run()
    return StdSchedules.runSystems(StartupSchedule)
end

return StartupSchedule
