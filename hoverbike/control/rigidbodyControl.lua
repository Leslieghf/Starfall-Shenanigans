local RigidbodyControl = {}

RigidbodyControl.MIN_FORCE = 0.001

local function magnitude(vec)
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end

function RigidbodyControl.getMass(propsRegistry)
    local totalMass = 0

    for _, prop in pairs(propsRegistry) do
        totalMass = totalMass + prop.ent:getMass()
    end

    if totalMass == 0 then return nil end
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
    
    for _, prop in pairs(propsRegistry) do
        local mass = prop.ent:getMass()
        local pos = prop.ent:getPos()
        totalMass = totalMass + mass
        weightedPos = weightedPos + pos * mass
    end
    
    if totalMass == 0 then return nil end
    return weightedPos / totalMass
end

function RigidbodyControl.applyLinearForce(chipEnt, propsRegistry, force)
    local comPos = RigidbodyControl.getCenterOfMass(chipEnt, propsRegistry)
    if magnitude(force) <= RigidbodyControl.MIN_FORCE then return Vector(), comPos end

    local totalMass = RigidbodyControl.getMass(propsRegistry)
    if not totalMass then return Vector(), comPos end

    local totalApplied = Vector()

    for _, prop in pairs(propsRegistry) do
        local ent = prop.ent
        local share = force * (ent:getMass() / totalMass)

        ent:applyForceOffset(share, ent:getPos())
        totalApplied = totalApplied + share
    end

    return totalApplied, comPos
end

return RigidbodyControl
