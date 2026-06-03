local RigidbodyControl = {}

function RigidbodyControl.getMass(propsRegistry)
    local totalMass = 0

    for _, prop in pairs(propsRegistry) do
        totalMass = totalMass + prop.ent:getMass()
    end

    return totalMass
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