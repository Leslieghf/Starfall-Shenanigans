--@include starfall_shenanigans/hoverbike/props/mod.lua
--@include starfall_shenanigans/hoverbike/debug/debug_lin_arrow.lua
--@include starfall_shenanigans/hoverbike/debug/debug_ang_arrow.lua

local Props = require("starfall_shenanigans/hoverbike/props/mod.lua")
local DebugLinArrow = require("starfall_shenanigans/hoverbike/debug/debug_lin_arrow.lua")
local DebugAngArrow = require("starfall_shenanigans/hoverbike/debug/debug_ang_arrow.lua")

local DebugVisualizer = {
    enabled = true,
    updateInterval = 0.02,
    nextUpdateAt = 0,

    linear = {
        deadzone = 0.5,
        minColor = Color(0, 255, 0, 255),
        maxColor = Color(255, 0, 0, 255),

        length = {
            base = 50,
            min = 25,
            max = 180,
            inputScale = 0.02,
            growth = 40
        },

        thickness = {
            base = 3,
            min = 3,
            max = 16,
            inputScale = 0.02,
            growth = 2
        },

        marker = {
            enabled = true,
            model = "models/hunter/misc/sphere025x025.mdl",
            scale = 0.15,
            color = Color(255, 255, 255, 255)
        }
    },

    angular = {
        enabled = true,
        deadzone = 0.5,
        minColor = Color(0, 255, 0, 204),
        maxColor = Color(255, 0, 0, 204),

        ring = {
            model = "models/hunter/tubes/tube4x4x025.mdl",
            radius = 41.75,
            scale = Vector(0.45, 0.45, 0.08),
            spinSpeed = 1,
            factor = {
                min = 0.75,
                max = 2,
                inputScale = 0.02,
                growth = 0.25
            }
        },

        heads = {
            model = "models/hunter/misc/cone2x2.mdl",
            count = 4,
            scale = Vector(0.1, 0.1, 0.1),
            factor = {
                min = 0.5,
                max = 3,
                inputScale = 0.02,
                growth = 0.7
            }
        },

        spear = {
            lengthFactor = 2.4,
            thickness = 1
        }
    }
}

local function cleanup()
    DebugLinArrow.cleanup()
    DebugAngArrow.cleanup()
end

function DebugVisualizer.cleanup()
    cleanup()
end

function DebugVisualizer.update(linInput, angInput)
    if not DebugVisualizer.enabled then
        cleanup()
        return
    end

    local chipEnt = chip()
    if not chipEnt or not chipEnt:isValid() then
        cleanup()
        return
    end

    local now = timer.curtime()
    if now < DebugVisualizer.nextUpdateAt then return end
    DebugVisualizer.nextUpdateAt = now + DebugVisualizer.updateInterval

    local origin = Props.getCenterOfMass(chipEnt) or chipEnt:getPos()
    DebugLinArrow.update(DebugVisualizer.linear, origin, linInput)
    DebugAngArrow.update(DebugVisualizer.angular, origin, angInput)
end

return DebugVisualizer
