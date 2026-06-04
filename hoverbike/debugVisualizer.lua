--@include propControl.lua
--@include rigidbodyControl.lua
--@include gizmoArrow.lua

local PropControl = require("propControl.lua")
local RigidbodyControl = require("rigidbodyControl.lua")
local GizmoArrow = require("gizmoArrow.lua")

local DebugVisualizer = {
    enabled = true,

    parts = {
        -- Corrects model-specific mismatch between reported bounds and the visible base.
        shaft = {
            model = "models/xqm/cylinderx1.mdl",
            forwardAxis = "x",
            length = 10,
            radius = 0.075,
            visualBaseOffset = 0
        },
        head = {
            model = "models/hunter/misc/cone2x2.mdl",
            forwardAxis = "z",
            scale = 0.025,
            gap = 0,
            visualBaseOffset = 4
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
}

local function cleanup()
    GizmoArrow.cleanup(DebugVisualizer)
end

function DebugVisualizer.update()
    if not DebugVisualizer.enabled then
        cleanup()
        return
    end

    local chipEnt = chip()
    if not chipEnt or not chipEnt:isValid() then
        cleanup()
        return
    end

    local origin = RigidbodyControl.getCenterOfMass(chipEnt, PropControl.Registry) or chipEnt:getPos()
    GizmoArrow.update(DebugVisualizer, origin)
end

function DebugVisualizer.cleanup()
    cleanup()
end

return DebugVisualizer
