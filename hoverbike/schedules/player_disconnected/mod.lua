--@include starfall_shenanigans/std/schedules/mod.lua

local StdSchedules = require("starfall_shenanigans/std/schedules/mod.lua")

local PlayerDisconnectedSchedule = StdSchedules.newSchedule("player_disconnected")

function PlayerDisconnectedSchedule.run(ply)
    return StdSchedules.runSystems(PlayerDisconnectedSchedule, ply)
end

return PlayerDisconnectedSchedule
