--@include debugDraw.lua

local Draw = require("debugDraw.lua")
local DebugLinArrow = {}

local state = {}
local SHAFT = { model = "models/xqm/cylinderx1.mdl", forwardAxis = "x", radius = 0.075 }
local HEAD = { model = "models/hunter/misc/cone2x2.mdl", forwardAxis = "z", localScale = Vector(0.025, 0.025, 0.025) }

local function arrowColor(config, length, thickness)
    local lengthAmount = Draw.rangeAmount(length, Draw.clamped(config.length.base, config.length.min, config.length.max), config.length.max)
    local thicknessAmount = Draw.rangeAmount(thickness, Draw.clamped(config.thickness.base, config.thickness.min, config.thickness.max), config.thickness.max)
    return Draw.gradientColor(config.minColor, config.maxColor, math.max(lengthAmount, thicknessAmount))
end

local function updateMarker(config, origin)
    local marker = config.marker
    if not marker.enabled then
        Draw.removeHolo(state, "marker")
        return
    end

    Draw.place(
        Draw.ensureHolo(state, "marker", marker.model),
        origin,
        Angle(),
        Vector(marker.scale, marker.scale, marker.scale),
        marker.color
    )
end

function DebugLinArrow.cleanup()
    Draw.removeKeys(state, {"marker", "shaft", "head"})
end

function DebugLinArrow.update(config, origin, input)
    updateMarker(config, origin)

    local inputMagnitude = Draw.magnitude(input)
    if inputMagnitude <= config.deadzone then
        Draw.removeKeys(state, {"shaft", "head"})
        return
    end

    local dir = input / inputMagnitude
    local length = Draw.metric(config.length, inputMagnitude)
    local thickness = Draw.metric(config.thickness, inputMagnitude)
    local color = arrowColor(config, length, thickness)

    Draw.placeLength(state, "shaft", SHAFT, origin, dir, length, SHAFT.radius * thickness, color)
    Draw.placeAtBase(state, "head", HEAD, origin + dir * length, dir, HEAD.localScale * thickness, color)
end

return DebugLinArrow
