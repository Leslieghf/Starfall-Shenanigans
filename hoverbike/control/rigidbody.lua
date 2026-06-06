--@include starfall_shenanigans/std/math/vector/mod.lua

local VectorMath = require("starfall_shenanigans/std/math/vector/mod.lua")

local Rigidbody = {}

Rigidbody.MIN_FORCE = 0.001

function Rigidbody.getMass(propsRegistry)
    local totalMass = 0

    for _, prop in pairs(propsRegistry) do
        totalMass = totalMass + prop.ent:getMass()
    end

    if totalMass == 0 then return nil end
    return totalMass
end

function Rigidbody.getAverageAngleVelocity(propsRegistry)
    local totalMass = 0
    local weightedAngVel = Vector()

    for _, prop in pairs(propsRegistry) do
        local mass = prop.ent:getMass()
        totalMass = totalMass + mass
        weightedAngVel = weightedAngVel + prop.ent:getAngleVelocity() * mass
    end

    if totalMass == 0 then return nil end
    return weightedAngVel / totalMass
end

function Rigidbody.getTotalInertia(propsRegistry)
    local totalInertia = Vector()
    local anyProp = false

    for _, prop in pairs(propsRegistry) do
        anyProp = true
        totalInertia = totalInertia + prop.ent:getInertia()
    end

    if not anyProp then return nil end
    return totalInertia
end

function Rigidbody.getCenterOfMass(chipEnt, propsRegistry)
    local totalMass = 0
    local weightedPos = Vector()
    
    for _, prop in pairs(propsRegistry) do
        local mass = prop.ent:getMass()
        local pos = prop.ent:getPos()
        totalMass = totalMass + mass
        weightedPos = weightedPos + pos * mass
    end
    
    if totalMass == 0 then return nil end
    return weightedPos / totalMass
end

function Rigidbody.applyLinearForce(chipEnt, force, comPos)
    if VectorMath.magnitude(force) <= Rigidbody.MIN_FORCE then return Vector(), comPos end

    chipEnt:applyForceOffset(force, comPos or chipEnt:getPos())

    return force, comPos
end

return Rigidbody
