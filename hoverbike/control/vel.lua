--@include ../constants.lua
--@include ../debug/log/mod.lua
--@include ../height/trace/mod.lua
--@include rigidbody.lua

local Constants = require("../constants.lua")
local Log = require("../debug/log/mod.lua")
local HeightTrace = require("../height/trace/mod.lua")
local Rigidbody = require("rigidbody.lua")

local Vel = {}

Vel.SPRING = 1.9
Vel.DAMPING = 1.5
Vel.MAX_DAMPING_IMPULSE_PER_MASS = 120
Vel.DEBUG = false

function Vel.getGravityCompensationForce(height, velZ, targetHeight, mass)
    if height > targetHeight then return Vector() end
    
    local influence = HeightTrace.getInfluence(height, velZ, targetHeight)
    
    return Vector(0, 0, Constants.BASE_GRAVITY * influence * mass)
end

function Vel.getSpringForce(height, velZ, targetHeight, mass)
    if height >= targetHeight then return Vector() end

    local error = targetHeight - height

    return Vector(0, 0, error * Vel.SPRING * mass)
end

function Vel.getDampingForce(height, velZ, targetHeight, mass)
    if velZ >= 0 then return Vector() end

    local influence = HeightTrace.getInfluence(height, velZ, targetHeight)
    local dampingImpulsePerMass = math.min(-velZ * Vel.DAMPING * influence, Vel.MAX_DAMPING_IMPULSE_PER_MASS)

    return Vector(0, 0, dampingImpulsePerMass * mass)
end

function Vel.applyForce(ent, gravityCompensationForce, springForce, dampingForce, comPos)
    local force = gravityCompensationForce + springForce + dampingForce

    return Rigidbody.applyLinearForce(ent, force, comPos)
end

function Vel.debugPrint(tr, height, targetHeight, velZ, mass, gravityForce, springForce, dampingForce, totalForce)
    if not Vel.DEBUG then return end

    local influence = HeightTrace.getInfluence(height, velZ, targetHeight)
    Log.debugPrint(string.format(
        "[hover-z] hit=%s h=%.2f target=%.2f err=%.2f vz=%.2f influence=%.3f mass=%.2f gravity=%.2f spring=%.2f damping=%.2f total=%.2f",
        tostring(tr.Hit),
        height,
        targetHeight,
        targetHeight - height,
        velZ,
        influence,
        mass,
        gravityForce.z,
        springForce.z,
        dampingForce.z,
        totalForce.z
    ))
end

function Vel.shouldApplyForce(tr, velZ)
    return tr.Hit
end

return Vel
