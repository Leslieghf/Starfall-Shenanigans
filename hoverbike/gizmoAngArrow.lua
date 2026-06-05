local GizmoAngArrow = {}

local modelBounds = {}

local function remove(holo)
    if holo and holo:isValid() then
        holo:remove()
    end
end

local function magnitude(vec)
    if not vec then return 0 end
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end

local function normalized(vec, len)
    len = len or magnitude(vec)
    if len <= 0.0001 then return nil end
    return vec / len
end

local function desaturate(value, gray, saturation)
    return gray + (value - gray) * saturation
end

local function directionColor(dir, fallback, saturation)
    fallback = fallback or Color(255, 255, 255, 255)
    saturation = saturation or 1
    if not dir then return fallback end

    local r = math.abs(dir.x) * 255
    local g = math.abs(dir.y) * 255
    local b = math.abs(dir.z) * 255
    local gray = (r + g + b) / 3

    return Color(
        math.floor(desaturate(r, gray, saturation)),
        math.floor(desaturate(g, gray, saturation)),
        math.floor(desaturate(b, gray, saturation)),
        fallback.a or 255
    )
end

local function axisInfo(axisName)
    local sign = 1
    local component = axisName

    if string.sub(axisName, 1, 1) == "-" then
        sign = -1
        component = string.sub(axisName, 2)
    end

    if component ~= "x" and component ~= "y" and component ~= "z" then
        error("Unsupported axis: " .. tostring(axisName))
    end

    return component, sign
end

local function component(vec, axisName)
    if axisName == "x" then return vec.x end
    if axisName == "y" then return vec.y end
    return vec.z
end

local function boundsFor(model)
    if modelBounds[model] then return modelBounds[model] end

    local probe = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
    local mins, maxs = probe:getModelBounds()
    modelBounds[model] = {
        mins = mins,
        maxs = maxs,
        size = maxs - mins
    }

    remove(probe)
    return modelBounds[model]
end

local function forwardPoint(part, bounds, t)
    local axis, sign = axisInfo(part.forwardAxis)
    local point = (bounds.mins + bounds.maxs) * 0.5
    local min = component(bounds.mins, axis)
    local max = component(bounds.maxs, axis)
    local value = sign > 0 and min + (max - min) * t or max - (max - min) * t

    if axis == "x" then
        point.x = value
    elseif axis == "y" then
        point.y = value
    else
        point.z = value
    end

    return point
end

local function forwardSpan(part, bounds)
    local axis = axisInfo(part.forwardAxis)
    return math.abs(component(bounds.size, axis))
end

local function scaleAlongForward(part, bounds, length, crossScale)
    local axis = axisInfo(part.forwardAxis)
    local along = length / math.max(forwardSpan(part, bounds), 0.001)

    if axis == "x" then return Vector(along, crossScale, crossScale) end
    if axis == "y" then return Vector(crossScale, along, crossScale) end
    return Vector(crossScale, crossScale, along)
end

local function clamped(value, min, max)
    if min and value < min then return min end
    if max and value > max then return max end
    return value
end

local function logScaled(base, factor, inputScale, inputMagnitude)
    return base + math.log(1 + inputMagnitude * inputScale) * factor
end

local function scaleFactor(config, inputMagnitude)
    return clamped(
        logScaled(config.minScaleFactor or 1, config.scaleLogFactor or 0, config.inputScale or 1, inputMagnitude),
        config.minScaleFactor,
        config.maxScaleFactor
    )
end

local function perpendicularTo(dir)
    local reference = math.abs(dir.z) < 0.95 and Vector(0, 0, 1) or Vector(0, 1, 0)
    local perpendicular = reference:cross(dir)
    return normalized(perpendicular) or Vector(1, 0, 0)
end

local function radialFor(first, second, degrees)
    local radians = math.rad(degrees)
    return first * math.cos(radians) + second * math.sin(radians)
end

local function basisFor(normal, phase)
    local first = perpendicularTo(normal)
    local second = normal:cross(first)

    if phase == 0 then return first, second end

    first = radialFor(first, second, phase)
    second = normal:cross(first)
    return first, second
end

local function angleFor(part, dir)
    local axis, sign = axisInfo(part.forwardAxis)
    local forward = sign > 0 and dir or dir * -1

    if axis == "x" then
        return forward:getAngle()
    end

    if axis == "z" then
        return perpendicularTo(forward):getAngleEx(forward)
    end

    error("Arbitrary-vector alignment currently supports local X or Z forward axes only")
end

local function scaledOffset(point, scale, angle)
    local offset = Vector(point.x * scale.x, point.y * scale.y, point.z * scale.z)
    offset:rotate(angle)
    return offset
end

local function positionAtBase(anchor, part, bounds, scale, angle)
    local offset = scaledOffset(forwardPoint(part, bounds, 0), scale, angle)
    return anchor - offset
end

local function ensureHolo(owner, key, model)
    local modelKey = key .. "Model"
    if owner[modelKey] ~= model then
        remove(owner[key])
        owner[key] = nil
    end

    if not owner[key] or not owner[key]:isValid() then
        owner[key] = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
        owner[modelKey] = model
    end

    return owner[key]
end

local function ensureUnclippedHolo(owner, key, model)
    local clipKey = key .. "UsesClip"
    if owner[clipKey] ~= false then
        remove(owner[key])
        owner[key] = nil
        owner[key .. "Model"] = nil
        owner[clipKey] = false
    end

    return ensureHolo(owner, key, model)
end

local function place(holo, pos, angle, scale, color)
    holo:setPos(pos)
    holo:setAngles(angle)
    holo:setScale(scale)
    holo:setColor(color)
end

local function ringScale(ring, factor)
    local scale = ring.scale or Vector(1, 1, 1)
    return Vector(scale.x * factor, scale.y * factor, scale.z)
end

local function cleanupHeads(gizmo, count)
    local oldCount = gizmo.headCount or 0
    for index = count + 1, oldCount do
        local key = "head" .. index
        remove(gizmo[key])
        gizmo[key] = nil
        gizmo[key .. "Model"] = nil
    end
    gizmo.headCount = count
end

local function cleanupVisuals(gizmo)
    remove(gizmo.ring)
    remove(gizmo.spearShaft)
    remove(gizmo.spearHead)
    gizmo.ring = nil
    gizmo.spearShaft = nil
    gizmo.spearHead = nil
    gizmo.ringModel = nil
    gizmo.spearShaftModel = nil
    gizmo.spearHeadModel = nil
    gizmo.spearShaftUsesClip = nil

    cleanupHeads(gizmo, 0)
    gizmo.headCount = nil
end

local function updateRing(gizmo, origin, dir, inputMagnitude, color)
    local ring = gizmo.ringConfig
    local head = gizmo.head
    local factor = scaleFactor(ring, inputMagnitude)
    local phase = timer.curtime() * (ring.spinSpeed or 0)
    local first, second = basisFor(dir, phase)
    local ringRadius = (ring.radius or 0) * factor
    local headCount = head.count or 4
    local headScale = head.localScale * scaleFactor(head, inputMagnitude)

    place(
        ensureHolo(gizmo, "ring", ring.model),
        origin,
        angleFor(ring, dir),
        ringScale(ring, factor),
        color
    )

    cleanupHeads(gizmo, headCount)
    for index = 1, headCount do
        local degrees = (index - 1) * 360 / headCount
        local radial = radialFor(first, second, degrees)
        local tangent = dir:cross(radial)

        place(
            ensureHolo(gizmo, "head" .. index, head.model),
            origin + radial * ringRadius,
            angleFor(head, tangent),
            headScale,
            color
        )
    end
end

local function updateSpear(gizmo, origin, dir, inputMagnitude, color)
    local spear = gizmo.spear
    local shaft = spear.shaft
    local head = spear.head
    local shaftBounds = boundsFor(shaft.model)
    local headBounds = boundsFor(head.model)
    local ringFactor = scaleFactor(gizmo.ringConfig, inputMagnitude)
    local length = (spear.length or ((gizmo.ringConfig.radius or 0) * (spear.lengthFactor or 2.4))) * ringFactor
    local halfLength = length * 0.5
    local thickness = (spear.thickness or 1) * ringFactor
    local shaftAngle = angleFor(shaft, dir)
    local headAngle = angleFor(head, dir)
    local shaftScale = scaleAlongForward(shaft, shaftBounds, length, (shaft.radius or 0.05) * thickness)
    local headScale = head.localScale * thickness
    local shaftStart = origin - dir * halfLength
    local shaftEnd = origin + dir * halfLength
    local shaftHolo = ensureUnclippedHolo(gizmo, "spearShaft", shaft.model)

    place(
        shaftHolo,
        positionAtBase(shaftStart, shaft, shaftBounds, shaftScale, shaftAngle),
        shaftAngle,
        shaftScale,
        color
    )

    place(
        ensureHolo(gizmo, "spearHead", head.model),
        positionAtBase(shaftEnd, head, headBounds, headScale, headAngle),
        headAngle,
        headScale,
        color
    )
end

function GizmoAngArrow.update(gizmo, origin, input)
    if not origin or gizmo.enabled == false then
        GizmoAngArrow.cleanup(gizmo)
        return
    end

    local inputMagnitude = magnitude(input)
    local dir = normalized(input, inputMagnitude)
    if not dir or inputMagnitude <= (gizmo.deadzone or 0) then
        cleanupVisuals(gizmo)
        return
    end

    local color = gizmo.colorByDirection and directionColor(dir, gizmo.color, gizmo.colorSaturation) or gizmo.color
    updateRing(gizmo, origin, dir, inputMagnitude, color)
    updateSpear(gizmo, origin, dir, inputMagnitude, color)
end

function GizmoAngArrow.cleanup(gizmo)
    cleanupVisuals(gizmo)
end

return GizmoAngArrow
