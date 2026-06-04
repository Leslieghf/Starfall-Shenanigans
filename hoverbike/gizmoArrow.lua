local GizmoArrow = {}

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

local function boundsFor(model)
    if modelBounds[model] then return modelBounds[model] end

    local probe = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
    local mins, maxs = probe:obbMins(), probe:obbMaxs()
    modelBounds[model] = { mins = mins, maxs = maxs, size = maxs - mins }

    remove(probe)
    return modelBounds[model]
end

local function scaleFor(part, bounds)
    if not part.length then
        local scale = part.scale or 1
        return Vector(scale, scale, scale)
    end

    local axis = axisInfo(part.forwardAxis)
    local along = part.length / math.max(component(bounds.size, axis), 0.001)
    local side = part.radius or 1

    if axis == "x" then return Vector(along, side, side) end
    if axis == "y" then return Vector(side, along, side) end
    return Vector(side, side, along)
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

local function basePoint(part, bounds)
    local axis, sign = axisInfo(part.forwardAxis)
    local edge = sign > 0 and bounds.mins or bounds.maxs
    local point = (bounds.mins + bounds.maxs) * 0.5

    if axis == "x" then
        point.x = edge.x
    elseif axis == "y" then
        point.y = edge.y
    else
        point.z = edge.z
    end

    return point
end

local function partState(part, worldAxis)
    local bounds = boundsFor(part.model)
    local scale = scaleFor(part, bounds)
    local angle = angleFor(part, worldAxis)
    local axis = axisInfo(part.forwardAxis)

    return bounds, scale, angle, math.abs(component(bounds.size, axis) * component(scale, axis))
end

local function positionAtBase(anchor, part, bounds, scale, angle, dir)
    local base = basePoint(part, bounds)
    local offset = Vector(base.x * scale.x, base.y * scale.y, base.z * scale.z)
    offset:rotate(angle)

    return anchor - offset - dir * (part.visualBaseOffset or 0)
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

local function updateArrow(gizmo, axis, origin)
    local dir = dirFor(axis.axis)
    local shaft = gizmo.parts.shaft
    local head = gizmo.parts.head
    local shaftBounds, shaftScale, shaftAngle, shaftLength = partState(shaft, axis.axis)
    local headBounds, headScale, headAngle = partState(head, axis.axis)
    local headBase = origin + dir * (shaftLength + (head.gap or 0))

    place(
        ensureHolo(axis, "shaft", shaft.model),
        positionAtBase(origin, shaft, shaftBounds, shaftScale, shaftAngle, dir),
        shaftAngle,
        shaftScale,
        axis.color
    )

    place(
        ensureHolo(axis, "head", head.model),
        positionAtBase(headBase, head, headBounds, headScale, headAngle, dir),
        headAngle,
        headScale,
        axis.color
    )
end

function GizmoArrow.update(gizmo, origin)
    updateCenterMarker(gizmo, origin)

    for _, axis in ipairs(gizmo.axes) do
        updateArrow(gizmo, axis, origin)
    end
end

function GizmoArrow.cleanup(gizmo)
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

return GizmoArrow
