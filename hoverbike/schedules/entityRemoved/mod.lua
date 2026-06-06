--@include ../../../std/schedules/mod.lua

local StdSchedules = require("../../../std/schedules/mod.lua")

local EntityRemovedSchedule = StdSchedules.newSchedule("entityRemoved")

function EntityRemovedSchedule.run(ent)
    return StdSchedules.runSystems(EntityRemovedSchedule, ent)
end

return EntityRemovedSchedule
