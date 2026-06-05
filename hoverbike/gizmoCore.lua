local GizmoCore = {}

local modelBounds = {}

function GizmoCore.remove(holo)
    if holo and holo:isValid() then
        holo:remove()
    end
end

function GizmoCore.magnitude(vec)
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end

function GizmoCore.normalized(vec, len)
    return vec / len
end

local function desaturate(value, gray, saturation)
    return gray + (value - gray) * saturation
end

function GizmoCore.directionColor(dir, baseColor, saturation)
    local r = math.abs(dir.x) * 255
    local g = math.abs(dir.y) * 255
    local b = math.abs(dir.z) * 255
    local gray = (r + g + b) / 3

    return Color(
        math.floor(desaturate(r, gray, saturation)),
        math.floor(desaturate(g, gray, saturation)),
        math.floor(desaturate(b, gray, saturation)),
        baseColor.a
    )
end

function GizmoCore.axisInfo(axisName)
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

function GizmoCore.component(vec, axisName)
    if axisName == "x" then return vec.x end
    if axisName == "y" then return vec.y end
    return vec.z
end

function GizmoCore.boundsFor(model)
    if modelBounds[model] then return modelBounds[model] end

    local probe = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
    local mins, maxs = probe:getModelBounds()
    modelBounds[model] = {
        mins = mins,
        maxs = maxs,
        size = maxs - mins
    }

    GizmoCore.remove(probe)
    return modelBounds[model]
end

function GizmoCore.forwardPoint(part, bounds, t)
    local axis, sign = GizmoCore.axisInfo(part.forwardAxis)
    local point = (bounds.mins + bounds.maxs) * 0.5
    local min = GizmoCore.component(bounds.mins, axis)
    local max = GizmoCore.component(bounds.maxs, axis)
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

function GizmoCore.forwardSpan(part, bounds)
    local axis = GizmoCore.axisInfo(part.forwardAxis)
    return math.abs(GizmoCore.component(bounds.size, axis))
end

function GizmoCore.scaleAlongForward(part, bounds, length, crossScale)
    local axis = GizmoCore.axisInfo(part.forwardAxis)
    local along = length / math.max(GizmoCore.forwardSpan(part, bounds), 0.001)

    if axis == "x" then return Vector(along, crossScale, crossScale) end
    if axis == "y" then return Vector(crossScale, along, crossScale) end
    return Vector(crossScale, crossScale, along)
end

function GizmoCore.clamped(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function GizmoCore.logScaled(base, factor, inputScale, inputMagnitude)
    return base + math.log(1 + inputMagnitude * inputScale) * factor
end

function GizmoCore.scaleFactor(config, inputMagnitude)
    return GizmoCore.clamped(
        GizmoCore.logScaled(config.minScaleFactor, config.scaleLogFactor, config.inputScale, inputMagnitude),
        config.minScaleFactor,
        config.maxScaleFactor
    )
end

function GizmoCore.perpendicularTo(dir)
    local reference = math.abs(dir.z) < 0.95 and Vector(0, 0, 1) or Vector(0, 1, 0)
    local perpendicular = reference:cross(dir)
    return GizmoCore.normalized(perpendicular, GizmoCore.magnitude(perpendicular))
end

function GizmoCore.radialFor(first, second, degrees)
    local radians = math.rad(degrees)
    return first * math.cos(radians) + second * math.sin(radians)
end

function GizmoCore.angleFor(part, dir)
    local axis, sign = GizmoCore.axisInfo(part.forwardAxis)
    local forward = sign > 0 and dir or dir * -1

    if axis == "x" then
        return forward:getAngle()
    end

    if axis == "z" then
        return GizmoCore.perpendicularTo(forward):getAngleEx(forward)
    end

    error("Arbitrary-vector alignment currently supports local X or Z forward axes only")
end

function GizmoCore.positionAtBase(anchor, part, bounds, scale, angle)
    local point = GizmoCore.forwardPoint(part, bounds, 0)
    local offset = Vector(point.x * scale.x, point.y * scale.y, point.z * scale.z)
    offset:rotate(angle)
    return anchor - offset
end

function GizmoCore.scaleToLength(part, length, crossScale)
    return GizmoCore.scaleAlongForward(part, GizmoCore.boundsFor(part.model), length, crossScale)
end

function GizmoCore.ensureHolo(owner, key, model)
    local modelKey = key .. "Model"
    if owner[modelKey] ~= model then
        GizmoCore.remove(owner[key])
        owner[key] = nil
    end

    if not owner[key] or not owner[key]:isValid() then
        owner[key] = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
        owner[modelKey] = model
    end

    return owner[key]
end

function GizmoCore.ensureParentedHolo(owner, key, model, parent)
    local modelKey = key .. "Model"
    local parentKey = key .. "Parent"
    local needsLayout = owner[modelKey] ~= model or owner[parentKey] ~= parent or not owner[key] or not owner[key]:isValid()
    local holo = GizmoCore.ensureHolo(owner, key, model)

    if owner[parentKey] ~= parent then
        holo:setParent(parent)
        owner[parentKey] = parent
    end

    return holo, needsLayout
end

function GizmoCore.place(holo, pos, angle, scale, color)
    holo:setPos(pos)
    holo:setAngles(angle)
    holo:setScale(scale)
    holo:setColor(color)
end

function GizmoCore.placeScaledPartAtBase(owner, key, part, anchor, dir, scale, color)
    local bounds = GizmoCore.boundsFor(part.model)
    local angle = GizmoCore.angleFor(part, dir)

    GizmoCore.place(
        GizmoCore.ensureHolo(owner, key, part.model),
        GizmoCore.positionAtBase(anchor, part, bounds, scale, angle),
        angle,
        scale,
        color
    )
end

function GizmoCore.placeLengthPartAtBase(owner, key, part, anchor, dir, length, crossScale, color)
    GizmoCore.placeScaledPartAtBase(
        owner,
        key,
        part,
        anchor,
        dir,
        GizmoCore.scaleToLength(part, length, crossScale),
        color
    )
end

function GizmoCore.placeLocal(holo, pos, angle, scale, color)
    holo:setLocalPos(pos)
    holo:setLocalAngles(angle)
    holo:setScale(scale)
    holo:setColor(color)
end

return GizmoCore
