--@include gizmoCore.lua

local Core = require("gizmoCore.lua")
local GizmoLinArrow = {}

local DEFAULT_SHAFT = {
    model = "models/xqm/cylinderx1.mdl",
    forwardAxis = "x",
    radius = 0.075
}

local DEFAULT_HEAD = {
    model = "models/hunter/misc/cone2x2.mdl",
    forwardAxis = "z",
    localScale = Vector(0.025, 0.025, 0.025)
}

local function cleanupCenterMarker(gizmo)
    Core.remove(gizmo.centerMarkerHolo)
    gizmo.centerMarkerHolo = nil
    gizmo.centerMarkerHoloModel = nil
end

local function updateCenterMarker(gizmo, origin)
    local marker = gizmo.centerMarker
    if not marker.enabled then
        cleanupCenterMarker(gizmo)
        return
    end

    local scale = marker.scale
    Core.place(
        Core.ensureHolo(gizmo, "centerMarkerHolo", marker.model),
        origin,
        Angle(),
        Vector(scale, scale, scale),
        marker.color
    )
end

local function cleanupArrow(gizmo)
    Core.remove(gizmo.shaft)
    Core.remove(gizmo.head)
    gizmo.shaft = nil
    gizmo.head = nil
    gizmo.shaftModel = nil
    gizmo.headModel = nil
end

local function arrowLength(arrow, magnitude)
    return Core.clamped(
        Core.logScaled(arrow.length, arrow.lengthLogFactor, arrow.lengthInputScale, magnitude),
        arrow.minLength,
        arrow.maxLength
    )
end

local function arrowThickness(arrow, magnitude)
    return Core.clamped(
        Core.logScaled(arrow.thickness, arrow.thicknessLogFactor, arrow.inputScale, magnitude),
        arrow.minThickness,
        arrow.maxThickness
    )
end

local function updateArrow(gizmo, origin, input)
    local inputMagnitude = Core.magnitude(input)
    local arrow = gizmo.arrow

    if inputMagnitude <= arrow.deadzone then
        cleanupArrow(gizmo)
        return
    end

    local dir = Core.normalized(input, inputMagnitude)
    local shaft = DEFAULT_SHAFT
    local head = DEFAULT_HEAD
    local length = arrowLength(arrow, inputMagnitude)
    local thickness = arrowThickness(arrow, inputMagnitude)
    local color = arrow.colorByDirection and Core.directionColor(dir, arrow.color, 1) or arrow.color
    local headScale = head.localScale * thickness
    local shaftEnd = origin + dir * length

    Core.placeLengthPartAtBase(gizmo, "shaft", shaft, origin, dir, length, shaft.radius * thickness, color)
    Core.placeScaledPartAtBase(gizmo, "head", head, shaftEnd, dir, headScale, color)
end

function GizmoLinArrow.update(gizmo, origin, input)
    updateCenterMarker(gizmo, origin)
    updateArrow(gizmo, origin, input)
end

function GizmoLinArrow.cleanup(gizmo)
    cleanupCenterMarker(gizmo)
    cleanupArrow(gizmo)
end

return GizmoLinArrow
