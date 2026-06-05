--@include propControl.lua
--@include rigidbodyControl.lua
--@include gizmoLinArrow.lua
--@include gizmoAngArrow.lua

local PropControl = require("propControl.lua")
local RigidbodyControl = require("rigidbodyControl.lua")
local GizmoLinArrow = require("gizmoLinArrow.lua")
local GizmoAngArrow = require("gizmoAngArrow.lua")

local DebugVisualizer = {
    enabled = true,
    updateInterval = 0.02,
    nextUpdateAt = 0,

    linArrow = {
        arrow = {
            length = 50,
            thickness = 1,
            maxThickness = 8,
            inputScale = 0.01,
            thicknessLogFactor = 1.2
        },

        parts = {
            shaft = {
                model = "models/xqm/cylinderx1.mdl",
                forwardAxis = "x",
                radius = 0.075,
                clipPaddingFactor = 0.25
            },
            head = {
                model = "models/hunter/misc/cone2x2.mdl",
                forwardAxis = "z",
                localScale = Vector(0.025, 0.025, 0.025)
            }
        },

        axes = {
            { axis = "x", color = Color(255, 80, 80, 255) },
            { axis = "y", color = Color(80, 255, 80, 255) },
            { axis = "z", color = Color(80, 160, 255, 255) }
        },

        centerMarker = {
            enabled = true,
            model = "models/hunter/misc/sphere025x025.mdl",
            scale = 0.15,
            color = Color(255, 255, 255, 255)
        }
    },

    angArrow = {
        enabled = true,

        ring = {
            model = "models/hunter/tubes/tube4x4x025.mdl",
            normalAxis = "z",
            radius = 41.75,
            scale = Vector(0.45, 0.45, 0.08)
        },

        head = {
            model = "models/hunter/misc/cone2x2.mdl",
            forwardAxis = "z",
            count = 4,
            localScale = Vector(0.1, 0.1, 0.1),
            minScaleFactor = 0.5,
            maxScaleFactor = 3,
            inputScale = 0.02,
            scaleLogFactor = 0.7
        },

        axes = {
            { axis = "x", color = Color(255, 80, 80, 255), direction = 1, spinSpeed = 1 },
            { axis = "y", color = Color(80, 255, 80, 255), direction = -1, spinSpeed = 1 },
            { axis = "z", color = Color(80, 160, 255, 255), direction = 1, spinSpeed = 1 }
        }
    }
}

local function cleanup()
    GizmoLinArrow.cleanup(DebugVisualizer.linArrow)
    GizmoAngArrow.cleanup(DebugVisualizer.angArrow)
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

    local origin = RigidbodyControl.getCenterOfMass(chipEnt, PropControl.Registry) or chipEnt:getPos()
    GizmoLinArrow.update(DebugVisualizer.linArrow, origin, linInput)
    GizmoAngArrow.update(DebugVisualizer.angArrow, origin, angInput)
end

function DebugVisualizer.cleanup()
    cleanup()
end

return DebugVisualizer
