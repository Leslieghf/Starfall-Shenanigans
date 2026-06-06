--@include ../utils.lua
--@include propControl.lua
--@include rigidbodyControl.lua

local Utils = require("../utils.lua")
local PropControl = require("propControl.lua")
local RigidbodyControl = require("rigidbodyControl.lua")

local VelControl = {}

VelControl.SPRING = 1.9
VelControl.DAMPING = 1.5
VelControl.MAX_DAMPING_IMPULSE_PER_MASS = 120
VelControl.DEBUG = false

function VelControl.getGravityCompensationForce(height, velZ, targetHeight, mass)
    if height > targetHeight then return Vector() end
    
    local influence = PropControl.getInfluence(height, velZ, targetHeight)
    
    return Vector(0, 0, Utils.BASE_GRAVITY * influence * mass)
end

function VelControl.getSpringForce(height, velZ, targetHeight, mass)
    if height >= targetHeight then return Vector() end

    local error = targetHeight - height

    return Vector(0, 0, error * VelControl.SPRING * mass)
end

function VelControl.getDampingForce(height, velZ, targetHeight, mass)
    if velZ >= 0 then return Vector() end

    local influence = PropControl.getInfluence(height, velZ, targetHeight)
    local dampingImpulsePerMass = math.min(-velZ * VelControl.DAMPING * influence, VelControl.MAX_DAMPING_IMPULSE_PER_MASS)

    return Vector(0, 0, dampingImpulsePerMass * mass)
end

function VelControl.applyForce(ent, propsRegistry, gravityCompensationForce, springForce, dampingForce)
    local force = gravityCompensationForce + springForce + dampingForce

    return RigidbodyControl.applyLinearForce(ent, propsRegistry, force)
end

function VelControl.debugPrint(tr, height, targetHeight, velZ, mass, gravityForce, springForce, dampingForce, totalForce)
    if not VelControl.DEBUG then return end

    local influence = PropControl.getInfluence(height, velZ, targetHeight)
    Utils.debugPrint(string.format(
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

function VelControl.shouldApplyForce(tr, velZ)
    return tr.Hit
end

return VelControl
