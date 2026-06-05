local GizmoLinArrow = {}

local ALIGN = {
    x = {
        x = Angle(0, 0, 0), y = Angle(0, 90, 0), z = Angle(-90, 0, 0),
        ["-x"] = Angle(0, 180, 0), ["-y"] = Angle(0, -90, 0), ["-z"] = Angle(90, 0, 0)
    },
    y = {
        x = Angle(0, -90, 0), y = Angle(0, 0, 0), z = Angle(0, 0, 90),
        ["-x"] = Angle(0, 90, 0), ["-y"] = Angle(0, 180, 0), ["-z"] = Angle(0, 0, -90)
    },
    z = {
        x = Angle(90, 0, 0), y = Angle(0, 0, -90), z = Angle(0, 0, 0),
        ["-x"] = Angle(-90, 0, 0), ["-y"] = Angle(0, 0, 90), ["-z"] = Angle(180, 0, 0)
    }
}

local modelBounds = {}

local function remove(holo)
    if holo and holo:isValid() then
        holo:remove()
    end
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

local function flipAxis(axisName)
    if string.sub(axisName, 1, 1) == "-" then return string.sub(axisName, 2) end
    return "-" .. axisName
end

local function dirFor(axisName)
    local axis, sign = axisInfo(axisName)
    if axis == "x" then return Vector(sign, 0, 0) end
    if axis == "y" then return Vector(0, sign, 0) end
    return Vector(0, 0, sign)
end

local function signedComponent(vec, axisName)
    if not vec then return 0 end

    local axis, sign = axisInfo(axisName)
    return component(vec, axis) * sign
end

local function vectorMagnitude(vec)
    if not vec then return 0 end
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end

local function displayAxis(axisName, value)
    if value < 0 then return flipAxis(axisName) end
    return axisName
end

local function logScaled(base, factor, inputScale, magnitude)
    return base + math.log(1 + magnitude * inputScale) * factor
end

local function clamped(value, min, max)
    if min and value < min then return min end
    if max and value > max then return max end
    return value
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

local function shaftScale(shaft, bounds, length, thickness)
    return scaleAlongForward(shaft, bounds, length, shaft.radius * thickness)
end

local function headScale(head, thickness)
    return head.localScale * thickness
end

local function clipPadding(part, length)
    return length * part.clipPaddingFactor
end

local function setShaftClips(holo, startPos, endPos, dir)
    holo:setClip(1, true, startPos, dir)
    holo:setClip(2, true, endPos, dir * -1)
end

local function angleFor(part, worldAxis)
    local localAxis, localSign = axisInfo(part.forwardAxis)
    local target = localSign > 0 and worldAxis or flipAxis(worldAxis)
    local angle = ALIGN[localAxis][target]

    if not angle then
        error("Unsupported axis alignment: " .. tostring(part.forwardAxis) .. " to " .. tostring(worldAxis))
    end

    return angle
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

local function updateArrow(gizmo, axis, origin, input)
    local arrow = gizmo.arrow
    local shaft = gizmo.parts.shaft
    local head = gizmo.parts.head
    local value = signedComponent(input, axis.axis)
    local magnitude = vectorMagnitude(input)
    local worldAxis = displayAxis(axis.axis, value)
    local dir = dirFor(worldAxis)
    local length = arrow.length
    local thickness = logScaled(
        arrow.thickness or 1,
        arrow.thicknessLogFactor or 0,
        arrow.inputScale or 1,
        magnitude
    )
    thickness = clamped(thickness, arrow.minThickness, arrow.maxThickness)
    local shaftBounds = boundsFor(shaft.model)
    local headBounds = boundsFor(head.model)
    local shaftAngle = angleFor(shaft, worldAxis)
    local headAngle = angleFor(head, worldAxis)
    local currentHeadScale = headScale(head, thickness)
    local shaftEnd = origin + dir * length
    local shaftPadding = clipPadding(shaft, length)
    local shaftRenderScale = shaftScale(shaft, shaftBounds, length + shaftPadding * 2, thickness)
    local shaftHolo = ensureHolo(axis, "shaft", shaft.model)

    place(
        shaftHolo,
        positionAtBase(
            origin - dir * shaftPadding,
            shaft,
            shaftBounds,
            shaftRenderScale,
            shaftAngle
        ),
        shaftAngle,
        shaftRenderScale,
        axis.color
    )
    setShaftClips(shaftHolo, origin, shaftEnd, dir)

    place(
        ensureHolo(axis, "head", head.model),
        positionAtBase(shaftEnd, head, headBounds, currentHeadScale, headAngle),
        headAngle,
        currentHeadScale,
        axis.color
    )
end

function GizmoLinArrow.update(gizmo, origin, input)
    updateCenterMarker(gizmo, origin)

    for _, axis in ipairs(gizmo.axes) do
        updateArrow(gizmo, axis, origin, input)
    end
end

function GizmoLinArrow.cleanup(gizmo)
    updateCenterMarker(gizmo, nil)

    for _, axis in ipairs(gizmo.axes) do
        remove(axis.shaft)
        remove(axis.head)
        axis.shaft = nil
        axis.head = nil
        axis.shaftModel = nil
        axis.headModel = nil
    end
end

return GizmoLinArrow
