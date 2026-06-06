--@include starfall_shenanigans/hoverbike/props/mod.lua

local Props = require("starfall_shenanigans/hoverbike/props/mod.lua")

local Systems = {}

local function startup()
    local chipEnt = chip()

    Props.registerPhysicalProp(chipEnt, Props.Types.CHIP_NAME)
    Props.Seat.spawn(chipEnt)
    Props.TestSphere.spawn(chipEnt)
end

local function updateSpawningAndPhysicalProperties()
    Props.update(chip())
end

function Systems.register(Schedules)
    Schedules.register(Schedules.STARTUP, "props.startup", startup)
    Schedules.register(Schedules.THINK, "props.updateSpawningAndPhysicalProperties", updateSpawningAndPhysicalProperties)
end

return Systems
