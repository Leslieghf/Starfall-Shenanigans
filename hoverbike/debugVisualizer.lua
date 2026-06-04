--@include propControl.lua
--@include rigidbodyControl.lua

local PropControl = require("propControl.lua")
local RigidbodyControl = require("rigidbodyControl.lua")

local DebugVisualizer = {
    enabled = true
}

DebugVisualizer.parts = {
    shaft = {
        model = "models/xqm/cylinderx1.mdl",
        forwardAxis = "x",
        length = 50,
        radius = 0.075,
        baseInset = 0
    },
    head = {
        model = "models/hunter/misc/cone2x2.mdl",
        forwardAxis = "z",
        scale = 0.025,
        gap = 0,
        baseInset = 1
    }
}

DebugVisualizer.axes = {
    { axis = "x", color = Color(255, 80, 80, 255) },
    { axis = "y", color = Color(80, 255, 80, 255) },
    { axis = "z", color = Color(80, 160, 255, 255) }
}

DebugVisualizer.anchorMarkers = {
    enabled = true,
    model = "models/hunter/misc/sphere025x025.mdl",
    scale = 0.15,
    originColor = Color(255, 255, 255, 255)
}

local WORLD_DIRS = {
    ["x"] = Vector(1, 0, 0),
    ["y"] = Vector(0, 1, 0),
    ["z"] = Vector(0, 0, 1),
    ["-x"] = Vector(-1, 0, 0),
    ["-y"] = Vector(0, -1, 0),
    ["-z"] = Vector(0, 0, -1)
}

local LOCAL_AXES = {
    ["x"] = { component = "x", sign = 1 },
    ["y"] = { component = "y", sign = 1 },
    ["z"] = { component = "z", sign = 1 },
    ["-x"] = { component = "x", sign = -1 },
    ["-y"] = { component = "y", sign = -1 },
    ["-z"] = { component = "z", sign = -1 }
}

local ALIGN_ANGLES = {
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

local function removeHolo(holo)
    if holo and holo:isValid() then
        holo:remove()
    end
end

local function axisInfo(axisName)
    local axis = LOCAL_AXES[axisName]
    if not axis then error("Unsupported local axis: " .. tostring(axisName)) end
    return axis
end

local function component(vec, axis)
    if axis == "x" then return vec.x end
    if axis == "y" then return vec.y end
    return vec.z
end

local function flipAxis(axisName)
    if string.sub(axisName, 1, 1) == "-" then return string.sub(axisName, 2) end
    return "-" .. axisName
end

local function worldDir(axisName)
    local dir = WORLD_DIRS[axisName]
    if not dir then error("Unsupported world axis: " .. tostring(axisName)) end
    return dir
end

local function getModelBounds(model)
    if modelBounds[model] then return modelBounds[model] end

    local probe = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
    local mins, maxs = probe:obbMins(), probe:obbMaxs()
    modelBounds[model] = { mins = mins, maxs = maxs, size = maxs - mins }

    removeHolo(probe)
    return modelBounds[model]
end

local function axisScale(axisName, along, side)
    local axis = axisInfo(axisName).component
    if axis == "x" then return Vector(along, side, side) end
    if axis == "y" then return Vector(side, along, side) end
    return Vector(side, side, along)
end

local function partScale(part, bounds)
    if not part.length then
        local scale = part.scale or 1
        return Vector(scale, scale, scale)
    end

    local axis = axisInfo(part.forwardAxis).component
    local along = part.length / math.max(component(bounds.size, axis), 0.001)
    return axisScale(part.forwardAxis, along, part.radius)
end

local function partLength(part, bounds, scale)
    local axis = axisInfo(part.forwardAxis).component
    return math.abs(component(bounds.size, axis) * component(scale, axis))
end

local function localBasePoint(part, bounds)
    local axis = axisInfo(part.forwardAxis)
    local edge = axis.sign > 0 and bounds.mins or bounds.maxs
    local point = (bounds.mins + bounds.maxs) * 0.5

    if axis.component == "x" then
        point.x = edge.x
    elseif axis.component == "y" then
        point.y = edge.y
    else
        point.z = edge.z
    end

    return point
end

local function scalePoint(point, scale)
    return Vector(point.x * scale.x, point.y * scale.y, point.z * scale.z)
end

local function positionForBase(anchor, part, bounds, scale, angle, dir)
    local offset = scalePoint(localBasePoint(part, bounds), scale)
    offset:rotate(angle)

    return anchor - offset - dir * (part.baseInset or 0)
end

local function partAngle(part, targetAxis)
    local axis = axisInfo(part.forwardAxis)
    local target = axis.sign > 0 and targetAxis or flipAxis(targetAxis)
    local angle = ALIGN_ANGLES[axis.component][target]

    if not angle then
        error("Unsupported axis alignment: " .. tostring(part.forwardAxis) .. " to " .. tostring(targetAxis))
    end

    return angle
end

local function ensurePart(axis, key, model)
    local modelKey = key .. "Model"
    if axis[modelKey] ~= model then
        removeHolo(axis[key])
        axis[key] = nil
    end

    if not axis[key] or not axis[key]:isValid() then
        axis[key] = hologram.create(Vector(), Angle(), model, Vector(1, 1, 1))
        axis[modelKey] = model
    end

    return axis[key]
end

local function setHolo(holo, pos, angle, scale, color)
    holo:setPos(pos)
    holo:setAngles(angle)
    holo:setScale(scale)
    holo:setColor(color)
end

local function removeMarker(owner, key)
    removeHolo(owner[key])
    owner[key] = nil
    owner[key .. "Model"] = nil
end

local function updateMarker(owner, key, pos, color)
    local marker = DebugVisualizer.anchorMarkers
    if not marker.enabled then
        removeMarker(owner, key)
        return
    end

    local scale = marker.scale or 1
    setHolo(
        ensurePart(owner, key, marker.model),
        pos,
        Angle(),
        Vector(scale, scale, scale),
        color
    )
end

local function updateArrow(axis, origin)
    local shaft = DebugVisualizer.parts.shaft
    local head = DebugVisualizer.parts.head
    local dir = worldDir(axis.axis)
    local shaftBounds = getModelBounds(shaft.model)
    local headBounds = getModelBounds(head.model)
    local shaftScale = partScale(shaft, shaftBounds)
    local headScale = partScale(head, headBounds)
    local shaftAngle = partAngle(shaft, axis.axis)
    local headAngle = partAngle(head, axis.axis)
    local headBase = origin + dir * (partLength(shaft, shaftBounds, shaftScale) + (head.gap or 0))

    updateMarker(axis, "jointMarker", headBase, axis.color)

    setHolo(
        ensurePart(axis, "shaft", shaft.model),
        positionForBase(origin, shaft, shaftBounds, shaftScale, shaftAngle, dir),
        shaftAngle,
        shaftScale,
        axis.color
    )

    setHolo(
        ensurePart(axis, "head", head.model),
        positionForBase(headBase, head, headBounds, headScale, headAngle, dir),
        headAngle,
        headScale,
        axis.color
    )
end

local function cleanupAxes()
    for _, axis in ipairs(DebugVisualizer.axes) do
        removeHolo(axis.shaft)
        removeHolo(axis.head)
        removeMarker(axis, "jointMarker")
        axis.shaft = nil
        axis.head = nil
        axis.shaftModel = nil
        axis.headModel = nil
    end

    removeMarker(DebugVisualizer, "originMarker")
end

function DebugVisualizer.update()
    if not DebugVisualizer.enabled then
        cleanupAxes()
        return
    end

    local chipEnt = chip()
    if not chipEnt or not chipEnt:isValid() then
        cleanupAxes()
        return
    end

    local origin = RigidbodyControl.getCenterOfMass(chipEnt, PropControl.Registry) or chipEnt:getPos()
    updateMarker(DebugVisualizer, "originMarker", origin, DebugVisualizer.anchorMarkers.originColor)

    for _, axis in ipairs(DebugVisualizer.axes) do
        updateArrow(axis, origin)
    end
end

function DebugVisualizer.cleanup()
    cleanupAxes()
end

return DebugVisualizer
