--@include starfall_shenanigans/std/schedules/mod.lua

local StdSchedules = require("starfall_shenanigans/std/schedules/mod.lua")

local PhysgunPickupSchedule = StdSchedules.newSchedule("physgun_pickup")

function PhysgunPickupSchedule.run(ply, ent)
    return StdSchedules.runSystems(PhysgunPickupSchedule, ply, ent)
end

return PhysgunPickupSchedule
