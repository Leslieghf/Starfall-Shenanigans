--@include starfall_shenanigans/std/schedules/classes.lua
--@include starfall_shenanigans/std/schedules/functions.lua

local Schedules = {}

Schedules.Classes = require("starfall_shenanigans/std/schedules/classes.lua")
Schedules.Functions = require("starfall_shenanigans/std/schedules/functions.lua")

Schedules.newSchedule = Schedules.Classes.newSchedule
Schedules.registerSystem = Schedules.Functions.registerSystem
Schedules.runSystems = Schedules.Functions.runSystems

return Schedules
