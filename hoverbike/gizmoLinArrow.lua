local GizmoLinArrow = {}

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

local function directionColor(dir, fallback)
    fallback = fallback or Color(255, 255, 255, 255)
    if not dir then return fallback end

    return Color(
        math.floor(math.abs(dir.x) * 255),
        math.floor(math.abs(dir.y) * 255),
        math.floor(math.abs(dir.z) * 255),
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

local function perpendicularTo(dir)
    local reference = math.abs(dir.z) < 0.95 and Vector(0, 0, 1) or Vector(0, 1, 0)
    local perpendicular = reference:cross(dir)
    return normalized(perpendicular) or Vector(1, 0, 0)
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

local function updateCenterMarker(gizmo, origin)
    local marker = gizmo.centerMarker
    if not origin or not marker or not marker.enabled then
        remove(gizmo.centerMarkerHolo)
        gizmo.centerMarkerHolo = nil
        gizmo.centerMarkerHoloModel = nil
        return
    end

    local scale = marker.scale or 1
    place(
        ensureHolo(gizmo, "centerMarkerHolo", marker.model),
        origin,
        Angle(),
        Vector(scale, scale, scale),
        marker.color
    )
end

local function cleanupArrow(gizmo)
    remove(gizmo.shaft)
    remove(gizmo.head)
    gizmo.shaft = nil
    gizmo.head = nil
    gizmo.shaftModel = nil
    gizmo.headModel = nil
    gizmo.shaftUsesClip = nil
end

local function updateArrow(gizmo, origin, input)
    local inputMagnitude = magnitude(input)
    local dir = normalized(input, inputMagnitude)
    local arrow = gizmo.arrow

    if not dir or inputMagnitude <= (arrow.deadzone or 0) then
        cleanupArrow(gizmo)
        return
    end

    local shaft = gizmo.parts.shaft
    local head = gizmo.parts.head
    local length = clamped(
        logScaled(arrow.length or 50, arrow.lengthLogFactor or 0, arrow.lengthInputScale or arrow.inputScale or 1, inputMagnitude),
        arrow.minLength,
        arrow.maxLength
    )
    local thickness = clamped(
        logScaled(arrow.thickness or 1, arrow.thicknessLogFactor or 0, arrow.inputScale or 1, inputMagnitude),
        arrow.minThickness,
        arrow.maxThickness
    )
    local color = arrow.colorByDirection and directionColor(dir, arrow.color) or arrow.color
    local shaftBounds = boundsFor(shaft.model)
    local headBounds = boundsFor(head.model)
    local shaftAngle = angleFor(shaft, dir)
    local headAngle = angleFor(head, dir)
    local shaftScale = scaleAlongForward(shaft, shaftBounds, length, (shaft.radius or 0.075) * thickness)
    local headScale = head.localScale * thickness
    local shaftEnd = origin + dir * length
    local shaftHolo = ensureUnclippedHolo(gizmo, "shaft", shaft.model)

    place(
        shaftHolo,
        positionAtBase(origin, shaft, shaftBounds, shaftScale, shaftAngle),
        shaftAngle,
        shaftScale,
        color
    )

    place(
        ensureHolo(gizmo, "head", head.model),
        positionAtBase(shaftEnd, head, headBounds, headScale, headAngle),
        headAngle,
        headScale,
        color
    )
end

function GizmoLinArrow.update(gizmo, origin, input)
    updateCenterMarker(gizmo, origin)
    updateArrow(gizmo, origin, input)
end

function GizmoLinArrow.cleanup(gizmo)
    updateCenterMarker(gizmo, nil)
    cleanupArrow(gizmo)
end

return GizmoLinArrow
