--@include ../../../std/schedules/mod.lua

local StdSchedules = require("../../../std/schedules/mod.lua")

local PlayerPhysicsPickupSchedule = StdSchedules.newSchedule("playerPhysicsPickup")

function PlayerPhysicsPickupSchedule.run(ply, ent)
    return StdSchedules.runSystems(PlayerPhysicsPickupSchedule, ply, ent)
end

return PlayerPhysicsPickupSchedule
