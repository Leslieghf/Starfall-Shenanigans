local RigidbodyControl = {}

function RigidbodyControl.getMass(propsRegistry)
    local totalMass = 0

    for _, prop in pairs(propsRegistry) do
        totalMass = totalMass + prop.ent:getMass()
    end

    return totalMass
end

function RigidbodyControl.getAverageAngleVelocity(propsRegistry)
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

function RigidbodyControl.getTotalInertia(propsRegistry)
    local totalInertia = Vector()
    local anyProp = false

    for _, prop in pairs(propsRegistry) do
        anyProp = true
        totalInertia = totalInertia + prop.ent:getInertia()
    end

    if not anyProp then return nil end
    return totalInertia
end

function RigidbodyControl.getCenterOfMass(chipEnt, propsRegistry)
    local totalMass = 0
    local weightedPos = Vector()
    
    for _, data in pairs(propsRegistry) do
        local mass = data.mass
        local pos = data.ent:getPos()
        totalMass = totalMass + mass
        weightedPos = weightedPos + pos * mass
    end
    
    if totalMass == 0 then return chipEnt:getPos() end
    
    return weightedPos / totalMass
end

return RigidbodyControl