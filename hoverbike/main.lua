--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl

local TARGET_HEIGHT = 100

local SPRING = 5
local DAMPING = 1.5

local BASE_GRAVITY = 9.01352

local function getGravityCompensationForce(mass)
    return Vector(0, 0, mass * BASE_GRAVITY)
end

local function getSpringForce(tr, pos, mass)
    if tr.Hit then
        local height = pos.z - tr.HitPos.z
        
        local error = TARGET_HEIGHT - height
        
        return Vector(0, 0, error * SPRING * mass)
    else
        return Vector()
    end
end

local function getDampingForce(velZ, mass)
    return Vector(0, 0, -velZ * DAMPING * mass)
end

local function shouldApplyTotalForce(tr, velZ, maxEntVelZ)
    return tr.Hit and (math.abs(velZ) <= maxEntVelZ)
end

local function applyTotalForce(ent, gravityCompensationForce, springForce, dampingForce)
    local force = gravityCompensationForce + springForce + dampingForce
    ent:applyForceCenter(force)
end

hook.add("think", "hover", function()
    local ent = chip()

    local pos = ent:getPos()
    local vel = ent:getVelocity()
    local mass = ent:getMass()

    local tr = trace.trace(
        pos - Vector(0, 0, 8),
        pos - Vector(0, 0, TARGET_HEIGHT * 4)
    )

    if shouldApplyTotalForce(tr, vel.z, 500) then
        applyTotalForce(
            ent,
            getGravityCompensationForce(mass),
            getSpringForce(tr, pos, mass),
            getDampingForce(vel.z, mass)
        )
    end

end)