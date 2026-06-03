--@include utils.lua

local Utils = require("utils.lua")

local VelControl = {}

VelControl.SPRING = 1.9
VelControl.DAMPING = 1.5

function VelControl.getGravityCompensationForce(height, velZ, mass)
    if height > Utils.TARGET_HEIGHT then return Vector() end
    
    local influence = Utils.getInfluence(height, velZ)
    
    return Vector(0, 0, Utils.BASE_GRAVITY * influence * mass)
end

function VelControl.getSpringForce(height, velZ, mass)
    if height >= Utils.TARGET_HEIGHT then return Vector() end

    local error = Utils.TARGET_HEIGHT - height

    return Vector(0, 0, error * VelControl.SPRING * mass)
end

function VelControl.getDampingForce(height, velZ, mass)
    if velZ >= 0 then return Vector() end

    local influence = Utils.getInfluence(height, velZ)

    return Vector(0, 0, -velZ * VelControl.DAMPING * influence * mass)
end

function VelControl.applyTotalForce(ent, gravityCompensationForce, springForce, dampingForce)
    local force = gravityCompensationForce + springForce + dampingForce
    ent:applyForceCenter(force)
end

function VelControl.shouldApplyTotalForce(tr, velZ)
    return tr.Hit
end

return VelControl