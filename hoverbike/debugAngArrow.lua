--@include debugDraw.lua

local Draw = require("debugDraw.lua")
local DebugAngArrow = {}

local state = {}
local LOCAL_X = Vector(1, 0, 0)
local LOCAL_Y = Vector(0, 1, 0)
local HEAD_PART = {forwardAxis = "z"}
local SPEAR_SHAFT = {model = "models/xqm/cylinderx1.mdl", forwardAxis = "x", radius = 0.045}
local SPEAR_HEAD = {model = "models/hunter/misc/cone2x2.mdl", forwardAxis = "z", localScale = Vector(0.045, 0.045, 0.045)}
local LAYOUT_RADIUS_STEP = 0.25
local LAYOUT_SCALE_STEP = 0.0025

local function cleanupHeads(count)
    for index = count + 1, state.headCount or 0 do
        Draw.removeHolo(state, "head" .. index)
    end
    state.headCount = count
end

local function cleanupVisuals()
    cleanupHeads(0)
    Draw.removeKeys(state, {"ring", "spearShaft", "spearHead"})
    state.headCount = nil
    state.headLayoutKey = nil
    state.ringTangent = nil
end

local function ringBaseTangent(dir)
    local tangent = state.ringTangent

    if tangent then
        tangent = tangent - dir * Draw.dot(tangent, dir)
        local length = Draw.magnitude(tangent)

        if length > 0.0001 then
            state.ringTangent = tangent / length
            return state.ringTangent
        end
    end

    local reference = math.abs(dir.z) < 0.95 and Vector(0, 0, 1) or Vector(0, 1, 0)
    local perpendicular = reference:cross(dir)
    state.ringTangent = perpendicular / Draw.magnitude(perpendicular)
    return state.ringTangent
end

local function quantized(value, step)
    return math.floor(value / step + 0.5) * step
end

local function layoutKey(headCount, ringRadius, headScale)
    return string.format(
        "%d:%.3f:%.4f:%.4f:%.4f",
        headCount,
        quantized(ringRadius, LAYOUT_RADIUS_STEP),
        quantized(headScale.x, LAYOUT_SCALE_STEP),
        quantized(headScale.y, LAYOUT_SCALE_STEP),
        quantized(headScale.z, LAYOUT_SCALE_STEP)
    )
end

local function arrowColor(config, ringFactor, headFactor)
    local ringAmount = Draw.rangeAmount(ringFactor, config.ring.factor.min, config.ring.factor.max)
    local headAmount = Draw.rangeAmount(headFactor, config.heads.factor.min, config.heads.factor.max)
    return Draw.gradientColor(config.minColor, config.maxColor, math.max(ringAmount, headAmount))
end

local function updateHead(config, index, ringHolo, ringRadius, headScale, color, layoutChanged)
    local degrees = (index - 1) * 360 / config.heads.count
    local radial = Draw.radialFor(LOCAL_X, LOCAL_Y, degrees)
    local tangent = Vector(-radial.y, radial.x, 0)
    local holo, needsLayout = Draw.ensureParentedHolo(state, "head" .. index, config.heads.model, ringHolo)

    HEAD_PART.model = config.heads.model
    if needsLayout or layoutChanged then
        holo:setLocalPos(radial * ringRadius)
        holo:setLocalAngles(Draw.angleFor(HEAD_PART, tangent))
        holo:setScale(headScale)
    end

    holo:setColor(color)
end

local function updateRing(config, origin, dir, ringFactor, headFactor, color)
    local tangent = ringBaseTangent(dir)
    local ringHolo = Draw.ensureHolo(state, "ring", config.ring.model)
    local ringRadius = config.ring.radius * ringFactor
    local headScale = config.heads.scale * headFactor

    Draw.place(
        ringHolo,
        origin,
        Draw.radialFor(tangent, dir:cross(tangent), timer.curtime() * config.ring.spinSpeed):getAngleEx(dir),
        Vector(config.ring.scale.x * ringFactor, config.ring.scale.y * ringFactor, config.ring.scale.z),
        color
    )

    cleanupHeads(config.heads.count)
    local currentLayoutKey = layoutKey(config.heads.count, ringRadius, headScale)
    local layoutChanged = state.headLayoutKey ~= currentLayoutKey

    for index = 1, config.heads.count do
        updateHead(config, index, ringHolo, ringRadius, headScale, color, layoutChanged)
    end

    state.headLayoutKey = currentLayoutKey
end

local function updateSpear(config, origin, dir, ringFactor, color)
    local length = config.ring.radius * config.spear.lengthFactor * ringFactor
    local halfLength = length * 0.5
    local thickness = config.spear.thickness * ringFactor

    Draw.placeLength(state, "spearShaft", SPEAR_SHAFT, origin - dir * halfLength, dir, length, SPEAR_SHAFT.radius * thickness, color)
    Draw.placeAtBase(state, "spearHead", SPEAR_HEAD, origin + dir * halfLength, dir, SPEAR_HEAD.localScale * thickness, color)
end

function DebugAngArrow.cleanup()
    cleanupVisuals()
end

function DebugAngArrow.update(config, origin, input)
    if config.enabled == false then
        cleanupVisuals()
        return
    end

    local inputMagnitude = Draw.magnitude(input)
    if inputMagnitude <= config.deadzone then
        cleanupVisuals()
        return
    end

    local dir = input / inputMagnitude
    local ringFactor = Draw.factor(config.ring.factor, inputMagnitude)
    local headFactor = Draw.factor(config.heads.factor, inputMagnitude)
    local color = arrowColor(config, ringFactor, headFactor)

    updateRing(config, origin, dir, ringFactor, headFactor, color)
    updateSpear(config, origin, dir, ringFactor, color)
end

return DebugAngArrow
