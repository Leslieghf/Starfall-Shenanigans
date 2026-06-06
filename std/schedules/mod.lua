--@include classes.lua
--@include functions.lua

local Schedules = {}

Schedules.Classes = require("classes.lua")
Schedules.Functions = require("functions.lua")

Schedules.newSchedule = Schedules.Classes.newSchedule
Schedules.registerSystem = Schedules.Functions.registerSystem
Schedules.runSystems = Schedules.Functions.runSystems

return Schedules
