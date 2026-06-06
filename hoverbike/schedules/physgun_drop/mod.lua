--@include starfall_shenanigans/std/schedules/mod.lua

local StdSchedules = require("starfall_shenanigans/std/schedules/mod.lua")

local PhysgunDropSchedule = StdSchedules.newSchedule("physgun_drop")

function PhysgunDropSchedule.run(ply, ent)
    return StdSchedules.runSystems(PhysgunDropSchedule, ply, ent)
end

return PhysgunDropSchedule
