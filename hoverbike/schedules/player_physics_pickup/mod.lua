--@include starfall_shenanigans/std/schedules/mod.lua

local StdSchedules = require("starfall_shenanigans/std/schedules/mod.lua")

local PlayerPhysicsPickupSchedule = StdSchedules.newSchedule("player_physics_pickup")

function PlayerPhysicsPickupSchedule.run(ply, ent)
    return StdSchedules.runSystems(PlayerPhysicsPickupSchedule, ply, ent)
end

return PlayerPhysicsPickupSchedule
