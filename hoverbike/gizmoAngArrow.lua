local GizmoAngArrow = {}

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

local function dirFor(axisName)
    local axis, sign = axisInfo(axisName)
    if axis == "x" then return Vector(sign, 0, 0) end
    if axis == "y" then return Vector(0, sign, 0) end
    return Vector(0, 0, sign)
end

local function component(vec, axisName)
    if axisName == "x" then return vec.x end
    if axisName == "y" then return vec.y end
    return vec.z
end

local function signedComponent(vec, axisName)
    if not vec then return nil end

    local axis, sign = axisInfo(axisName)
    return component(vec, axis) * sign
end

local function flipAxis(axisName)
    if string.sub(axisName, 1, 1) == "-" then return string.sub(axisName, 2) end
    return "-" .. axisName
end

local function angleFromAxis(localAxisName, worldAxisName)
    local localAxis, localSign = axisInfo(localAxisName)
    local target = localSign > 0 and worldAxisName or flipAxis(worldAxisName)
    local angle = ALIGN[localAxis][target]

    if not angle then
        error("Unsupported axis alignment: " .. tostring(localAxisName) .. " to " .. tostring(worldAxisName))
    end

    return angle
end

local function basisFor(axisName)
    local axis = axisInfo(axisName)
    local normal = dirFor(axisName)
    local first

    if axis == "x" then
        first = Vector(0, 1, 0)
    elseif axis == "y" then
        first = Vector(0, 0, 1)
    else
        first = Vector(1, 0, 0)
    end

    return normal, first, normal:cross(first)
end

local function radialFor(first, second, degrees)
    local radians = math.rad(degrees)
    return first * math.cos(radians) + second * math.sin(radians)
end

local function tangentFor(normal, radial, direction)
    return normal:cross(radial) * direction
end

local function directionSign(direction)
    return (direction or 1) < 0 and -1 or 1
end

local function clamped(value, min, max)
    if min and value < min then return min end
    if max and value > max then return max end
    return value
end

local function directionFor(axis, value)
    if value and value ~= 0 then
        return value < 0 and -1 or 1
    end

    return directionSign(axis.direction)
end

local function logScaleFactor(head, magnitude)
    local minScaleFactor = head.minScaleFactor or 1
    local maxScaleFactor = head.maxScaleFactor
    local inputScale = head.inputScale or 1
    local scaleLogFactor = head.scaleLogFactor or 0

    return clamped(
        minScaleFactor + math.log(1 + magnitude * inputScale) * scaleLogFactor,
        minScaleFactor,
        maxScaleFactor
    )
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

local function ringAngle(ring, axisName, normal, phase)
    local angle = angleFromAxis(ring.normalAxis, axisName):clone()
    angle:rotateAroundAxis(normal, phase)
    return angle
end

local function headAngle(head, radial, tangent)
    if head.forwardAxis == "z" then
        return radial:getAngleEx(tangent)
    end

    if head.forwardAxis == "x" then
        return tangent:getAngle()
    end

    error("Unsupported angular arrow head axis: " .. tostring(head.forwardAxis))
end

local function cleanupExtraHeads(axis, count)
    local oldCount = axis.headCount or 0
    for index = count + 1, oldCount do
        local key = "head" .. index
        remove(axis[key])
        axis[key] = nil
        axis[key .. "Model"] = nil
    end
    axis.headCount = count
end

local function updateRing(gizmo, axis, origin, input)
    local ring = gizmo.ring
    local head = gizmo.head
    local normal, first, second = basisFor(axis.axis)
    local value = signedComponent(input, axis.axis)
    local direction = directionFor(axis, value)
    local phase = timer.curtime() * (axis.spinSpeed or 0) * direction
    local headCount = head.count or 4
    local currentHeadScale = head.localScale * logScaleFactor(head, math.abs(value or 0))

    place(
        ensureHolo(axis, "ring", ring.model),
        origin,
        ringAngle(ring, axis.axis, normal, phase),
        ring.scale,
        axis.color
    )

    cleanupExtraHeads(axis, headCount)
    for index = 1, headCount do
        local degrees = phase + (index - 1) * 360 / headCount
        local radial = radialFor(first, second, degrees)
        local tangent = tangentFor(normal, radial, direction)

        place(
            ensureHolo(axis, "head" .. index, head.model),
            origin + radial * (ring.radius or 0),
            headAngle(head, radial, tangent),
            currentHeadScale,
            axis.color
        )
    end
end

function GizmoAngArrow.update(gizmo, origin, input)
    if not origin or gizmo.enabled == false then
        GizmoAngArrow.cleanup(gizmo)
        return
    end

    for _, axis in ipairs(gizmo.axes) do
        updateRing(gizmo, axis, origin, input)
    end
end

function GizmoAngArrow.cleanup(gizmo)
    for _, axis in ipairs(gizmo.axes) do
        remove(axis.ring)
        axis.ring = nil
        axis.ringModel = nil

        local headCount = axis.headCount or gizmo.head.count or 4
        for index = 1, headCount do
            local key = "head" .. index
            remove(axis[key])
            axis[key] = nil
            axis[key .. "Model"] = nil
        end
        axis.headCount = nil
    end
end

return GizmoAngArrow
