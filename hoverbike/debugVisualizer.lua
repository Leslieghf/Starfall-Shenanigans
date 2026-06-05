--@include propControl.lua
--@include rigidbodyControl.lua
--@include gizmoCore.lua
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
            minLength = 25,
            maxLength = 180,
            lengthInputScale = 0.02,
            lengthLogFactor = 40,
            thickness = 3,
            minThickness = 3,
            maxThickness = 16,
            inputScale = 0.02,
            thicknessLogFactor = 2,
            deadzone = 0.5,
            minColor = Color(0, 255, 0, 255),
            maxColor = Color(255, 0, 0, 255)
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
        deadzone = 0.5,
        minColor = Color(0, 255, 0, 204),
        maxColor = Color(255, 0, 0, 204),

        ringConfig = {
            model = "models/hunter/tubes/tube4x4x025.mdl",
            forwardAxis = "z",
            radius = 41.75,
            scale = Vector(0.45, 0.45, 0.08),
            spinSpeed = 1,
            minScaleFactor = 0.75,
            maxScaleFactor = 2,
            inputScale = 0.02,
            scaleLogFactor = 0.25,
            layoutRadiusStep = 0.25,
            layoutScaleStep = 0.0025
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

        spear = {
            lengthFactor = 2.4,
            thickness = 1,
            shaft = {
                model = "models/xqm/cylinderx1.mdl",
                forwardAxis = "x",
                radius = 0.045
            },
            head = {
                model = "models/hunter/misc/cone2x2.mdl",
                forwardAxis = "z",
                localScale = Vector(0.045, 0.045, 0.045)
            }
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
