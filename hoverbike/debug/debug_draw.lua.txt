local DebugDraw = {}

local modelBounds = {}

function DebugDraw.magnitude(vec)
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end

function DebugDraw.dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

function DebugDraw.clamped(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function DebugDraw.rangeAmount(value, min, max)
    return DebugDraw.clamped((value - min) / (max - min), 0, 1)
end

function DebugDraw.metric(spec, inputMagnitude)
    return DebugDraw.clamped(
        spec.base + math.log(1 + inputMagnitude * spec.inputScale) * spec.growth,
        spec.min,
        spec.max
    )
end

function DebugDraw.factor(spec, inputMagnitude)
    return DebugDraw.clamped(
        spec.min + math.log(1 + inputMagnitude * spec.inputScale) * spec.growth,
        spec.min,
        spec.max
    )
end

function DebugDraw.gradientColor(minColor, maxColor, amount)
    local t = DebugDraw.clamped(amount, 0, 1)
    return Color(
        math.floor(minColor.r + (maxColor.r - minColor.r) * t),
        math.floor(minColor.g + (maxColor.g - minColor.g) * t),
        math.floor(minColor.b + (maxColor.b - minColor.b) * t),
        math.floor(minColor.a + (maxColor.a - minColor.a) * t)
    )
end

function DebugDraw.radialFor(first, second, degrees)
    local radians = math.rad(degrees)
    return first * math.cos(radians) + second * math.sin(radians)
end

function DebugDraw.removeHolo(owner, key)
    local holo = owner[key]
    if holo and holo:isValid() then holo:remove() end
    owner[key] = nil
    owner[key .. "Model"] = nil
    owner[key .. "Parent"] = nil
end

function DebugDraw.removeKeys(owner, keys)
    for _, key in ipairs(keys) do
        DebugDraw.removeHolo(owner, key)
    end
end

function DebugDraw.ensureHolo(owner, key, model)
    if owner[key .. "Model"] ~= model then DebugDraw.removeHolo(owner, key) end
    if not owner[key] or not owner[key]:isValid() then
        owner[key] = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
        owner[key .. "Model"] = model
    end
    return owner[key]
end

function DebugDraw.ensureParentedHolo(owner, key, model, parent)
    local modelChanged = owner[key .. "Model"] ~= model
    local parentChanged = owner[key .. "Parent"] ~= parent
    local missing = not owner[key] or not owner[key]:isValid()
    local holo = DebugDraw.ensureHolo(owner, key, model)

    if modelChanged or parentChanged or missing then
        holo:setParent(parent)
        owner[key .. "Parent"] = parent
    end

    return holo, modelChanged or parentChanged or missing
end

local function boundsFor(model)
    if modelBounds[model] then return modelBounds[model] end

    local probe = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
    local mins, maxs = probe:getModelBounds()
    if probe and probe:isValid() then probe:remove() end
    modelBounds[model] = {mins = mins, maxs = maxs, size = maxs - mins}
    return modelBounds[model]
end

local function perpendicularTo(dir)
    local reference = math.abs(dir.z) < 0.95 and Vector(0, 0, 1) or Vector(0, 1, 0)
    local perpendicular = reference:cross(dir)
    return perpendicular / DebugDraw.magnitude(perpendicular)
end

function DebugDraw.angleFor(part, dir)
    if part.forwardAxis == "x" then return dir:getAngle() end
    if part.forwardAxis == "z" then return perpendicularTo(dir):getAngleEx(dir) end
    error("Unsupported forward axis: " .. tostring(part.forwardAxis))
end

local function basePoint(part, bounds)
    local point = (bounds.mins + bounds.maxs) * 0.5

    if part.forwardAxis == "x" then
        point.x = bounds.mins.x
    elseif part.forwardAxis == "z" then
        point.z = bounds.mins.z
    else
        error("Unsupported forward axis: " .. tostring(part.forwardAxis))
    end

    return point
end

local function lengthScale(part, length, crossScale)
    local bounds = boundsFor(part.model)

    if part.forwardAxis == "x" then
        return Vector(length / math.max(bounds.size.x, 0.001), crossScale, crossScale)
    end

    if part.forwardAxis == "z" then
        return Vector(crossScale, crossScale, length / math.max(bounds.size.z, 0.001))
    end

    error("Unsupported forward axis: " .. tostring(part.forwardAxis))
end

function DebugDraw.place(holo, pos, angle, scale, color)
    holo:setPos(pos)
    holo:setAngles(angle)
    holo:setScale(scale)
    holo:setColor(color)
end

function DebugDraw.placeAtBase(owner, key, part, anchor, dir, scale, color)
    local angle = DebugDraw.angleFor(part, dir)
    local base = basePoint(part, boundsFor(part.model))
    local offset = Vector(base.x * scale.x, base.y * scale.y, base.z * scale.z)

    offset:rotate(angle)
    DebugDraw.place(DebugDraw.ensureHolo(owner, key, part.model), anchor - offset, angle, scale, color)
end

function DebugDraw.placeLength(owner, key, part, anchor, dir, length, crossScale, color)
    DebugDraw.placeAtBase(owner, key, part, anchor, dir, lengthScale(part, length, crossScale), color)
end

return DebugDraw
