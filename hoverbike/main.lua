--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl

local TARGET_HEIGHT = 100
local INFLUENCE_FALLOFF_EXPONENT = 4
local LOOKAHEAD_TIME = 0.5

local SPRING = 1.9
local DAMPING = 1.5
local DAMPING_FALLOFF_HEIGHT = TARGET_HEIGHT * 2
local ROTATIONAL_DAMPING = 0.01

local BASE_GRAVITY = 9.01352

local function isNotChip(ent)
    return ent ~= chip()
end

local function getHeightTrace(pos)
    return trace.trace(
        pos,
        pos - Vector(0, 0, TARGET_HEIGHT * 4),
        isNotChip
    )
end

local function getHeight(tr, pos)
    return pos.z - tr.HitPos.z
end

local function getTimeToTarget(height, velZ)
    if velZ >= 0 then return math.huge end

    local distanceToTarget = math.max(height - TARGET_HEIGHT, 0)

    return distanceToTarget / math.max(-velZ, 1)
end

local function getInfluence(height, velZ)
    local timeToTarget = getTimeToTarget(height, velZ)
    local t = math.clamp(timeToTarget / LOOKAHEAD_TIME, 0, 1)

    return (1 - t)^INFLUENCE_FALLOFF_EXPONENT
end

local function getGravityCompensationForce(height, velZ, mass)
    if height > TARGET_HEIGHT then return Vector() end
    
    local influence = getInfluence(height, velZ)
    
    return Vector(0, 0, BASE_GRAVITY * influence * mass)
end

local function getSpringForce(height, velZ, mass)
    if height >= TARGET_HEIGHT then return Vector() end

    local error = TARGET_HEIGHT - height

    return Vector(0, 0, error * SPRING * mass)
end

local function getDampingForce(height, velZ, mass)
    if velZ >= 0 then return Vector() end

    local influence = getInfluence(height, velZ)

    return Vector(0, 0, -velZ * DAMPING * influence * mass)
end

local function getRotationalDampingTorque(ent)

    local angVel = ent:getAngleVelocity()
    local inertia = ent:getInertia()

    return Vector(
        -angVel.x * inertia.x,
        -angVel.y * inertia.y,
        -angVel.z * inertia.z
    ) * ROTATIONAL_DAMPING

end

local function shouldApplyTotalForce(tr, velZ)
    return tr.Hit
end

local function applyTotalForce(ent, gravityCompensationForce, springForce, dampingForce)
    local force = gravityCompensationForce + springForce + dampingForce
    ent:applyForceCenter(force)
end

local function applyTotalTorque(ent, dampingTorque)
    local torque = dampingTorque
    ent:applyTorque(torque)
end

hook.add("think", "hover", function()
    local ent = chip()
    local pos = ent:getPos()
    local vel = ent:getVelocity()
    local mass = ent:getMass()
    local tr = getHeightTrace(pos)
    local height = getHeight(tr, pos)

    if shouldApplyTotalForce(tr, vel.z) then
        applyTotalForce(
            ent,
            getGravityCompensationForce(height, vel.z, mass),
            getSpringForce(height, vel.z, mass),
            getDampingForce(height, vel.z, mass)
        )
    end
    
    -- applyTotalTorque(ent, getRotationalDampingTorque(ent))
end)