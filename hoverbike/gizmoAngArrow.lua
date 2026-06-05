--@include gizmoCore.lua

local Core = require("gizmoCore.lua")
local GizmoAngArrow = {}

local LOCAL_X = Vector(1, 0, 0)
local LOCAL_Y = Vector(0, 1, 0)

local function ringScale(ring, factor)
    local scale = ring.scale
    return Vector(scale.x * factor, scale.y * factor, scale.z)
end

local function cleanupHeads(gizmo, count)
    local oldCount = gizmo.headCount or 0
    for index = count + 1, oldCount do
        local key = "head" .. index
        Core.remove(gizmo[key])
        gizmo[key] = nil
        gizmo[key .. "Model"] = nil
        gizmo[key .. "Parent"] = nil
    end
    gizmo.headCount = count
end

local function cleanupVisuals(gizmo)
    cleanupHeads(gizmo, 0)

    Core.remove(gizmo.ring)
    Core.remove(gizmo.spearShaft)
    Core.remove(gizmo.spearHead)
    gizmo.ring = nil
    gizmo.spearShaft = nil
    gizmo.spearHead = nil
    gizmo.ringModel = nil
    gizmo.spearShaftModel = nil
    gizmo.spearHeadModel = nil
    gizmo.headCount = nil
    gizmo.headLayoutKey = nil
end

local function ringAngleFor(ring, dir, phase)
    local angle = Core.angleFor(ring, dir)
    angle:rotateAroundAxis(dir, phase)
    return angle
end

local function quantized(value, step)
    return math.floor(value / step + 0.5) * step
end

local function layoutKey(headCount, ringRadius, headScale, ring)
    local radiusStep = ring.layoutRadiusStep
    local scaleStep = ring.layoutScaleStep

    return string.format(
        "%d:%.3f:%.4f:%.4f:%.4f",
        headCount,
        quantized(ringRadius, radiusStep),
        quantized(headScale.x, scaleStep),
        quantized(headScale.y, scaleStep),
        quantized(headScale.z, scaleStep)
    )
end

local function updateRingHead(gizmo, index, head, ringHolo, ringRadius, headScale, color, layoutChanged)
    local degrees = (index - 1) * 360 / head.count
    local radial = Core.radialFor(LOCAL_X, LOCAL_Y, degrees)
    local tangent = Vector(-radial.y, radial.x, 0)
    local headHolo, needsLayout = Core.ensureParentedHolo(gizmo, "head" .. index, head.model, ringHolo)

    if needsLayout or layoutChanged then
        Core.placeLocal(headHolo, radial * ringRadius, Core.angleFor(head, tangent), headScale, color)
    else
        headHolo:setColor(color)
    end
end

local function arrowColor(gizmo, ringFactor, headFactor)
    local ring = gizmo.ringConfig
    local head = gizmo.head
    local amount = math.max(
        Core.rangeAmount(ringFactor, ring.minScaleFactor, ring.maxScaleFactor),
        Core.rangeAmount(headFactor, head.minScaleFactor, head.maxScaleFactor)
    )

    return Core.gradientColor(gizmo.minColor, gizmo.maxColor, amount)
end

local function updateRing(gizmo, origin, dir, ringFactor, headFactor, color)
    local ring = gizmo.ringConfig
    local head = gizmo.head
    local phase = timer.curtime() * ring.spinSpeed
    local ringRadius = ring.radius * ringFactor
    local headCount = head.count
    local headScale = head.localScale * headFactor
    local ringHolo = Core.ensureHolo(gizmo, "ring", ring.model)

    Core.place(
        ringHolo,
        origin,
        ringAngleFor(ring, dir, phase),
        ringScale(ring, ringFactor),
        color
    )

    cleanupHeads(gizmo, headCount)
    local currentLayoutKey = layoutKey(headCount, ringRadius, headScale, ring)
    local layoutChanged = gizmo.headLayoutKey ~= currentLayoutKey

    for index = 1, headCount do
        updateRingHead(gizmo, index, head, ringHolo, ringRadius, headScale, color, layoutChanged)
    end

    gizmo.headLayoutKey = currentLayoutKey
end

local function updateSpear(gizmo, origin, dir, ringFactor, color)
    local spear = gizmo.spear
    local shaft = spear.shaft
    local head = spear.head
    local length = gizmo.ringConfig.radius * spear.lengthFactor * ringFactor
    local halfLength = length * 0.5
    local thickness = spear.thickness * ringFactor
    local headScale = head.localScale * thickness
    local shaftStart = origin - dir * halfLength
    local shaftEnd = origin + dir * halfLength

    Core.placeLengthPartAtBase(gizmo, "spearShaft", shaft, shaftStart, dir, length, shaft.radius * thickness, color)
    Core.placeScaledPartAtBase(gizmo, "spearHead", head, shaftEnd, dir, headScale, color)
end

function GizmoAngArrow.update(gizmo, origin, input)
    if gizmo.enabled == false then
        GizmoAngArrow.cleanup(gizmo)
        return
    end

    local inputMagnitude = Core.magnitude(input)
    if inputMagnitude <= gizmo.deadzone then
        cleanupVisuals(gizmo)
        return
    end

    local dir = Core.normalized(input, inputMagnitude)
    local ringFactor = Core.scaleFactor(gizmo.ringConfig, inputMagnitude)
    local headFactor = Core.scaleFactor(gizmo.head, inputMagnitude)
    local color = arrowColor(gizmo, ringFactor, headFactor)
    updateRing(gizmo, origin, dir, ringFactor, headFactor, color)
    updateSpear(gizmo, origin, dir, ringFactor, color)
end

function GizmoAngArrow.cleanup(gizmo)
    cleanupVisuals(gizmo)
end

return GizmoAngArrow
