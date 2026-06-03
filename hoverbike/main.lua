--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl

local TARGET_HEIGHT = 100
local MAX_HOVER_FORCE_INFLUENCE_HEIGHT = 200
local MAX_VELOCITY_Z = 500 -- Misleading name; this does NOT mean that 500 is the fastest the hoverbike can move!

local SPRING = 5
local DAMPING = 1.5

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

local function getGravityCompensationForce(tr, pos, mass)
    local height = pos.z - tr.HitPos.z
    
    if height > TARGET_HEIGHT then return Vector() end
    
    return Vector(0, 0, mass * BASE_GRAVITY)
end

local function getSpringForce(tr, pos, velZ, mass)
    if !tr.Hit then return Vector() end

    local height = pos.z - tr.HitPos.z

    if height >= TARGET_HEIGHT then return Vector() end

    local error = TARGET_HEIGHT - height

    return Vector(0, 0, error * SPRING * mass)
end

local function getDampingForce(tr, pos, velZ, mass)
    local height = pos.z - tr.HitPos.z
    
    if height > TARGET_HEIGHT then return Vector() end
    
    return Vector(0, 0, -velZ * DAMPING * mass)
end

local function shouldApplyTotalForce(tr, velZ)
    return tr.Hit and (math.abs(velZ) <= MAX_VELOCITY_Z)
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

    local tr = getHeightTrace(pos)

    if shouldApplyTotalForce(tr, vel.z) then
        applyTotalForce(
            ent,
            getGravityCompensationForce(tr, pos, mass),
            getSpringForce(tr, pos, vel.z, mass),
            getDampingForce(tr, pos, vel.z, mass)
        )
    end

end)