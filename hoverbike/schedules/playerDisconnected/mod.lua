--@include ../../../std/schedules/mod.lua

local StdSchedules = require("../../../std/schedules/mod.lua")

local PlayerDisconnectedSchedule = StdSchedules.newSchedule("playerDisconnected")

function PlayerDisconnectedSchedule.run(ply)
    return StdSchedules.runSystems(PlayerDisconnectedSchedule, ply)
end

return PlayerDisconnectedSchedule
