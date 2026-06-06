--@include ../../std/math/scalar/mod.lua
--@include ../../std/math/vector/mod.lua

local ScalarMath = require("../../std/math/scalar/mod.lua")
local VectorMath = require("../../std/math/vector/mod.lua")

local AngVel = {}
AngVel.UPRIGHT_FACTOR = 150.0
AngVel.UPRIGHT_DAMPING_RATIO = 1.25
AngVel.UPRIGHT_INTEGRAL_FACTOR = 20.0
AngVel.UPRIGHT_INTEGRAL_LIMIT = 0.35
AngVel.UPRIGHT_INTEGRAL_DECAY = 0.75
AngVel.UPRIGHT_INTEGRAL_MAX_DT = 0.05
AngVel.ERROR_DEADZONE = 0.003
AngVel.ANGVEL_DEADZONE = 0.1
AngVel.TARGET_UP = Vector(0, 0, 1)
AngVel.UprightIntegral = Vector()
AngVel.LastUpdateAt = nil
AngVel.LastTorqueAt = nil

local LOCAL_UP = Vector(0, 0, 1)
local RAD_TO_DEG = 180 / math.pi

local function uprightDampingFactor()
    return 2 * AngVel.UPRIGHT_DAMPING_RATIO * math.sqrt(AngVel.UPRIGHT_FACTOR)
end

function AngVel.getUprightErrorAxis(ent, targetUp)
    local currentUp = VectorMath.normalized(VectorMath.localToWorld(ent, LOCAL_UP))
    local normalizedTargetUp = VectorMath.normalized(targetUp)
    local errorAxis = currentUp:cross(normalizedTargetUp)
    local errorLength = VectorMath.magnitude(errorAxis)
    local alignment = ScalarMath.clamp(VectorMath.dot(currentUp, normalizedTargetUp), -1, 1)

    if errorLength > 0.0001 then
        return errorAxis / errorLength * math.acos(alignment)
    end

    if alignment < 0 then
        return VectorMath.localToWorld(ent, Vector(1, 0, 0)) * math.pi
    end

    return Vector()
end

local function updateUprightIntegral(errorAxis)
    local now = timer.curtime()
    local dt = AngVel.LastUpdateAt and now - AngVel.LastUpdateAt or 0
    dt = math.min(dt, AngVel.UPRIGHT_INTEGRAL_MAX_DT)
    AngVel.LastUpdateAt = now
    local decay = math.max(0, 1 - AngVel.UPRIGHT_INTEGRAL_DECAY * dt)
    AngVel.UprightIntegral = VectorMath.clampedMagnitude(
        AngVel.UprightIntegral * decay + errorAxis * dt,
        AngVel.UPRIGHT_INTEGRAL_LIMIT
    )

    return AngVel.UprightIntegral
end

function AngVel.setTargetUp(targetUp)
    AngVel.TARGET_UP = VectorMath.normalized(targetUp)
    AngVel.resetState()
end

function AngVel.resetState()
    AngVel.UprightIntegral = Vector()
    AngVel.LastUpdateAt = nil
    AngVel.LastTorqueAt = nil
end

function AngVel.shouldApplyTorque(ent, uprightErrorAxis)
    return
        VectorMath.magnitude(uprightErrorAxis) > AngVel.ERROR_DEADZONE or
        VectorMath.magnitude(AngVel.UprightIntegral) > AngVel.ERROR_DEADZONE or
        VectorMath.magnitude(ent:getAngleVelocity()) > AngVel.ANGVEL_DEADZONE
end

function AngVel.getRotationalDampingTorque(ent, inertia)
    local angVel = ent:getAngleVelocity()

    return VectorMath.localInertiaTorqueToWorld(ent, inertia, angVel, -uprightDampingFactor())
end

function AngVel.getUprightSpringTorque(ent, inertia, uprightErrorAxis)
    local localErrorAxis = VectorMath.worldToLocal(ent, uprightErrorAxis) * RAD_TO_DEG

    return VectorMath.localInertiaTorqueToWorld(ent, inertia, localErrorAxis, AngVel.UPRIGHT_FACTOR)
end

function AngVel.getUprightIntegralTorque(ent, inertia, uprightErrorAxis)
    local integralAxis = updateUprightIntegral(uprightErrorAxis)
    local localIntegralAxis = VectorMath.worldToLocal(ent, integralAxis) * RAD_TO_DEG

    return VectorMath.localInertiaTorqueToWorld(ent, inertia, localIntegralAxis, AngVel.UPRIGHT_INTEGRAL_FACTOR)
end

function AngVel.applyTorque(ent, springTorque, integralTorque, dampingTorque)
    local now = timer.curtime()
    local dt = AngVel.LastTorqueAt and now - AngVel.LastTorqueAt or 0
    dt = math.min(dt, AngVel.UPRIGHT_INTEGRAL_MAX_DT)
    AngVel.LastTorqueAt = now

    local torque = springTorque + integralTorque + dampingTorque
    local angularImpulse = torque * dt
    ent:applyTorque(angularImpulse)
    return angularImpulse
end

return AngVel
