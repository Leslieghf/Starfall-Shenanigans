--@include starfall_shenanigans/std/schedules/mod.lua

local StdSchedules = require("starfall_shenanigans/std/schedules/mod.lua")

local EntityRemovedSchedule = StdSchedules.newSchedule("entity_removed")

function EntityRemovedSchedule.run(ent)
    return StdSchedules.runSystems(EntityRemovedSchedule, ent)
end

return EntityRemovedSchedule
