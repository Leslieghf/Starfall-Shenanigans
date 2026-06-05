local AngVelControl = {}
AngVelControl.UPRIGHT_FACTOR = 150.0
AngVelControl.UPRIGHT_DAMPING_RATIO = 0.9
AngVelControl.UPRIGHT_INTEGRAL_FACTOR = 150.0
AngVelControl.UPRIGHT_INTEGRAL_LIMIT = 5.0
AngVelControl.UPRIGHT_INTEGRAL_MAX_DT = 0.05
AngVelControl.ERROR_DEADZONE = 0.001
AngVelControl.ANGVEL_DEADZONE = 0.001
AngVelControl.TARGET_UP = Vector(0, 0, 1)
AngVelControl.UprightIntegral = Vector()
AngVelControl.LastUpdateAt = nil

local LOCAL_UP = Vector(0, 0, 1)

local function localVectorToWorld(ent, vec)
    return ent:localToWorld(vec) - ent:getPos()
end

local function worldVectorToLocal(ent, vec)
    return ent:worldToLocal(ent:getPos() + vec)
end

local function magnitude(vec)
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end

local function normalized(vec)
    return vec / magnitude(vec)
end

local function dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

local function clampedMagnitude(vec, limit)
    local length = magnitude(vec)
    if length <= limit then return vec end
    return vec / length * limit
end

local function localInertiaTorqueToWorld(ent, inertia, localAxis, factor)
    return localVectorToWorld(ent, inertia * localAxis * factor)
end

local function uprightDampingFactor()
    return 2 * AngVelControl.UPRIGHT_DAMPING_RATIO * math.sqrt(AngVelControl.UPRIGHT_FACTOR)
end

function AngVelControl.getUprightErrorAxis(ent, targetUp)
    local currentUp = localVectorToWorld(ent, LOCAL_UP)
    local normalizedTargetUp = normalized(targetUp)
    local errorAxis = currentUp:cross(normalizedTargetUp)

    if magnitude(errorAxis) > 0.0001 then
        return errorAxis
    end

    if dot(currentUp, normalizedTargetUp) < 0 then
        return localVectorToWorld(ent, Vector(1, 0, 0))
    end

    return Vector()
end

local function updateUprightIntegral(errorAxis)
    local now = timer.curtime()
    local dt = AngVelControl.LastUpdateAt and now - AngVelControl.LastUpdateAt or 0
    dt = math.min(dt, AngVelControl.UPRIGHT_INTEGRAL_MAX_DT)
    AngVelControl.LastUpdateAt = now
    AngVelControl.UprightIntegral = clampedMagnitude(
        AngVelControl.UprightIntegral + errorAxis * dt,
        AngVelControl.UPRIGHT_INTEGRAL_LIMIT
    )

    return AngVelControl.UprightIntegral
end

function AngVelControl.setTargetUp(targetUp)
    AngVelControl.TARGET_UP = normalized(targetUp)
    AngVelControl.UprightIntegral = Vector()
    AngVelControl.LastUpdateAt = nil
end

function AngVelControl.shouldApplyTorque(ent, uprightErrorAxis)
    return
        magnitude(uprightErrorAxis) > AngVelControl.ERROR_DEADZONE or
        magnitude(AngVelControl.UprightIntegral) > AngVelControl.ERROR_DEADZONE or
        magnitude(ent:getAngleVelocity()) > AngVelControl.ANGVEL_DEADZONE
end

function AngVelControl.getRotationalDampingTorque(ent, inertia)
    local angVel = ent:getAngleVelocity()

    return localInertiaTorqueToWorld(ent, inertia, angVel, -uprightDampingFactor())
end

function AngVelControl.getUprightSpringTorque(ent, inertia, uprightErrorAxis)
    local localErrorAxis = worldVectorToLocal(ent, uprightErrorAxis)

    return localInertiaTorqueToWorld(ent, inertia, localErrorAxis, AngVelControl.UPRIGHT_FACTOR)
end

function AngVelControl.getUprightIntegralTorque(ent, inertia, uprightErrorAxis)
    local integralAxis = updateUprightIntegral(uprightErrorAxis)
    local localIntegralAxis = worldVectorToLocal(ent, integralAxis)

    return localInertiaTorqueToWorld(ent, inertia, localIntegralAxis, AngVelControl.UPRIGHT_INTEGRAL_FACTOR)
end

function AngVelControl.applyTorque(ent, springTorque, integralTorque, dampingTorque)
    local torque = springTorque + integralTorque + dampingTorque
    ent:applyTorque(torque)
    return torque
end

return AngVelControl
