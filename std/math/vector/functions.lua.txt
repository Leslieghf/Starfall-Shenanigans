local VectorFunctions = {}

function VectorFunctions.magnitude(vec)
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end

function VectorFunctions.normalized(vec)
    local length = VectorFunctions.magnitude(vec)
    if length <= 0 then return Vector() end

    return vec / length
end

function VectorFunctions.dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

function VectorFunctions.clampedMagnitude(vec, limit)
    local length = VectorFunctions.magnitude(vec)
    if length <= limit then return vec end

    return vec / length * limit
end

function VectorFunctions.localToWorld(ent, vec)
    return ent:localToWorld(vec) - ent:getPos()
end

function VectorFunctions.worldToLocal(ent, vec)
    return ent:worldToLocal(ent:getPos() + vec)
end

function VectorFunctions.localInertiaTorqueToWorld(ent, inertia, localAxis, factor)
    return VectorFunctions.localToWorld(ent, inertia * localAxis * factor)
end

function VectorFunctions.horizontalLocalDirection(ent, localAxis, minMagnitude)
    local direction = VectorFunctions.localToWorld(ent, localAxis)
    direction.z = 0

    local length = VectorFunctions.magnitude(direction)
    if length <= minMagnitude then return Vector() end

    return direction / length
end

return VectorFunctions
