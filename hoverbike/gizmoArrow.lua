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

local function readBounds(ent)
    for _, methodName in ipairs({ "getModelBounds" }) do
        local method = ent[methodName]
        if method then
            local ok, mins, maxs = pcall(function()
                return method(ent)
            end)

            if ok and mins and maxs then return mins, maxs end
        end
    end

    return ent:obbMins(), ent:obbMaxs()
end

local function boundsFor(model)
    if modelBounds[model] then return modelBounds[model] end

    local probe = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
    local mins, maxs = readBounds(probe)
    modelBounds[model] = {
        mins = mins,
        maxs = maxs,
        center = (mins + maxs) * 0.5,
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

local function scaleForLength(part, bounds, length)
    local axis = axisInfo(part.forwardAxis)
    local along = length / math.max(forwardSpan(part, bounds), 0.001)
    local side = part.radius or 1

    if axis == "x" then return Vector(along, side, side) end
    if axis == "y" then return Vector(side, along, side) end
    return Vector(side, side, along)
end

local function scaleFor(part, bounds)
    if part.length then
        return scaleForLength(part, bounds, part.length)
    end

    local scale = part.scale or 1
    return Vector(scale, scale, scale)
end

local function lengthFor(part, bounds, scale)
    if part.length then
        return part.length
    end

    local axis = axisInfo(part.forwardAxis)
    return math.abs(forwardSpan(part, bounds) * component(scale, axis))
end

local function clipPadding(part, length)
    if not part.clipEndpoints then return 0 end

    return length * (part.clipPaddingFactor or 0.25)
end

local function setShaftClips(holo, enabled, startPos, endPos, dir)
    if not enabled then
        holo:setClip(1, false)
        holo:setClip(2, false)
        return
    end

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

local function partState(part, worldAxis)
    local bounds = boundsFor(part.model)
    local scale = scaleFor(part, bounds)
    local angle = angleFor(part, worldAxis)
    local length = lengthFor(part, bounds, scale)

    return bounds, scale, angle, length
end

local function scaledOffset(point, scale, angle)
    local offset = Vector(point.x * scale.x, point.y * scale.y, point.z * scale.z)
    offset:rotate(angle)
    return offset
end

local function positionAtBase(anchor, part, bounds, scale, angle, dir, contactInset)
    local offset = scaledOffset(forwardPoint(part, bounds, 0), scale, angle)
    return anchor - offset - dir * (contactInset or 0)
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
    local shaftBounds, _, shaftAngle, shaftLength = partState(shaft, axis.axis)
    local headBounds, headScale, headAngle = partState(head, axis.axis)
    local shaftEnd = origin + dir * shaftLength
    local headBase = shaftEnd + dir * (head.gap or 0)
    local shaftPadding = clipPadding(shaft, shaftLength)
    local shaftRenderScale = scaleForLength(shaft, shaftBounds, shaftLength + shaftPadding * 2)
    local shaftHolo = ensureHolo(axis, "shaft", shaft.model)

    place(
        shaftHolo,
        positionAtBase(
            origin - dir * shaftPadding,
            shaft,
            shaftBounds,
            shaftRenderScale,
            shaftAngle,
            dir,
            0
        ),
        shaftAngle,
        shaftRenderScale,
        axis.color
    )
    setShaftClips(shaftHolo, shaft.clipEndpoints, origin, shaftEnd, dir)

    place(
        ensureHolo(axis, "head", head.model),
        positionAtBase(headBase, head, headBounds, headScale, headAngle, dir, head.contactInset),
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
