--@include ../../../std/schedules/mod.lua

local StdSchedules = require("../../../std/schedules/mod.lua")

local StartupSchedule = StdSchedules.newSchedule("startup")

function StartupSchedule.run()
    return StdSchedules.runSystems(StartupSchedule)
end

return StartupSchedule
