--@include ../../../std/schedules/mod.lua

local StdSchedules = require("../../../std/schedules/mod.lua")

local PhysgunPickupSchedule = StdSchedules.newSchedule("physgunPickup")

function PhysgunPickupSchedule.run(ply, ent)
    return StdSchedules.runSystems(PhysgunPickupSchedule, ply, ent)
end

return PhysgunPickupSchedule
