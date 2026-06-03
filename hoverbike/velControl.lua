--@include utils.lua
--@include propControl.lua
--@include rigidbodyControl.lua

local Utils = require("utils.lua")
local PropControl = require("propControl.lua")
local RigidbodyControl = require("rigidbodyControl.lua")

local VelControl = {}

VelControl.SPRING = 1.9
VelControl.DAMPING = 1.5

function VelControl.getGravityCompensationForce(height, velZ, mass)
    if height > Utils.TARGET_HEIGHT then return Vector() end
    
    local influence = PropControl.getInfluence(height, velZ)
    
    return Vector(0, 0, Utils.BASE_GRAVITY * influence * mass)
end

function VelControl.getSpringForce(height, velZ, mass)
    if height >= Utils.TARGET_HEIGHT then return Vector() end

    local error = Utils.TARGET_HEIGHT - height

    return Vector(0, 0, error * VelControl.SPRING * mass)
end

function VelControl.getDampingForce(height, velZ, mass)
    if velZ >= 0 then return Vector() end

    local influence = PropControl.getInfluence(height, velZ)

    return Vector(0, 0, -velZ * VelControl.DAMPING * influence * mass)
end

function VelControl.applyForce(ent, propsRegistry, gravityCompensationForce, springForce, dampingForce)
    local force = gravityCompensationForce + springForce + dampingForce
    local comPos = RigidbodyControl.getCenterOfMass(ent, propsRegistry)
    local chipPos = ent:getPos()
    local offset = comPos - chipPos
    
    -- print("Applying force '" .. tostring(force) .. "' with offset '" .. tostring(offset) .. "'.")
    
    ent:applyForceOffset(force, offset)
end

function VelControl.shouldApplyForce(tr, velZ)
    return tr.Hit
end

return VelControl