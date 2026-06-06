--@include ../../../std/schedules/mod.lua

local StdSchedules = require("../../../std/schedules/mod.lua")

local PhysgunDropSchedule = StdSchedules.newSchedule("physgunDrop")

function PhysgunDropSchedule.run(ply, ent)
    return StdSchedules.runSystems(PhysgunDropSchedule, ply, ent)
end

return PhysgunDropSchedule
