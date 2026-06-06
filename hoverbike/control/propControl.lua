--@include ../utils.lua
--@include ../pipeline.lua
--@include ../cache.lua

local Utils = require("../utils.lua")
local Pipeline = require("../pipeline.lua")
local Cache = require("../cache.lua")

local PropControl = {}

PropControl.PhysicalRegistry = {}
PropControl.DecorativeRegistry = {}
PropControl.TEST_SPHERE_MODEL = "models/props_c17/oildrum001.mdl"
PropControl.TEST_SPHERE_COUNT = 20
PropControl.TEST_SPHERE_RADIUS = 50
PropControl.TEST_SPHERE_MAX_POLAR_DEGREES = 85
PropControl.SpawnPipeline = Pipeline.new("prop_spawns")

local function buildPhysicalProperties(chipEnt)
    local totalMass = 0
    local totalInertia = Vector()
    local weightedLocalPos = Vector()

    for _, prop in pairs(PropControl.PhysicalRegistry) do
        local ent = prop.ent
        local mass = ent:getMass()

        totalMass = totalMass + mass
        totalInertia = totalInertia + ent:getInertia()
        weightedLocalPos = weightedLocalPos + chipEnt:worldToLocal(ent:getPos()) * mass
    end

    if totalMass == 0 then return {} end

    return {
        mass = totalMass,
        inertia = totalInertia,
        localCenterOfMass = weightedLocalPos / totalMass
    }
end

PropControl.PhysicalPropertiesCache = Cache.new(
    buildPhysicalProperties,
    Utils.PHYSICAL_PROPERTIES_REFRESH_INTERVAL
)

function PropControl.spawn(pos, ang, model, frozen, complete)
    PropControl.SpawnPipeline:enqueue(
        function()
            return prop.create(pos, ang, model, frozen)
        end,
        complete
    )
end

function PropControl.spawnSeat(pos, ang, model, frozen, complete)
    PropControl.SpawnPipeline:enqueue(
        function()
            return prop.createSeat(pos, ang, model, frozen)
        end,
        complete
    )
end

function PropControl.update(chipEnt)
    PropControl.SpawnPipeline:processWhile(prop.canSpawn)

    if PropControl.PhysicalPropertiesCache:shouldRefresh() then
        PropControl.PhysicalPropertiesCache:refresh(chipEnt)
    end
end

local function randomUpperSphereDirection()
    local minZ = math.cos(math.rad(PropControl.TEST_SPHERE_MAX_POLAR_DEGREES))
    local z = minZ + math.random() * (1 - minZ)
    local phi = math.random() * math.pi * 2
    local xy = math.sqrt(1 - z * z)

    return Vector(math.cos(phi) * xy, math.sin(phi) * xy, z)
end

local function addTestSphere(chipEnt)
    local center = chipEnt:getPos()
    local ang = chipEnt:getAngles()

    for i = 1, PropControl.TEST_SPHERE_COUNT do
        local direction = randomUpperSphereDirection()
        local pos = center + direction * PropControl.TEST_SPHERE_RADIUS

        PropControl.spawn(pos, ang, PropControl.TEST_SPHERE_MODEL, false, function(drum)
            drum:setParent(chipEnt)
            PropControl.addDecorativeProp(drum)
        end)
    end
end

function PropControl.startup()
    -- Chip
    local chip = chip()
    PropControl.addPhysicalProp(chip, "chip")

    -- Seat
    local seatPos = chip:getPos() + Vector(0, 0, 11)
    local seatAng = chip:getAngles()
    local seatModel = "models/props_phx/carseat3.mdl"
    local seatFrozen = true
    PropControl.spawnSeat(seatPos, seatAng, seatModel, seatFrozen, function(seat)
        constraint.weld(seat, chip)
        PropControl.addPhysicalProp(seat, "seat")
    end)

    addTestSphere(chip)
end

function PropControl.addPhysicalProp(ent, name)
    PropControl.PhysicalRegistry[name] = {ent = ent}
    PropControl.PhysicalPropertiesCache:invalidate()
end

function PropControl.addDecorativeProp(ent)
    ent:disablePhysgun(true)
    ent:setFrozen(true)
    table.insert(PropControl.DecorativeRegistry, ent)
end

function PropControl.getPhysicalProperties()
    return PropControl.PhysicalPropertiesCache:get()
end

function PropControl.getMass()
    return PropControl.getPhysicalProperties().mass
end

function PropControl.getTotalInertia()
    return PropControl.getPhysicalProperties().inertia
end

function PropControl.getCenterOfMass(chipEnt)
    local localCenterOfMass = PropControl.getPhysicalProperties().localCenterOfMass
    if not localCenterOfMass then return nil end

    return chipEnt:localToWorld(localCenterOfMass)
end

function PropControl.isPhysicalProp(ent)
    for _, physicalProp in pairs(PropControl.PhysicalRegistry) do
        if ent == physicalProp.ent then return true end
    end

    return false
end

function PropControl.isDecorativeProp(ent)
    for _, decorativeProp in ipairs(PropControl.DecorativeRegistry) do
        if ent == decorativeProp then return true end
    end

    return false
end

function PropControl.shouldHitHeightTrace(ent)
    if PropControl.isPhysicalProp(ent) then return false end
    if PropControl.isDecorativeProp(ent) then return false end
    if ent:isPlayer() or ent:isWeapon() or ent:isNPC() or ent:isVehicle() or ent:isNextBot() then return false end

    return true
end

function PropControl.getHeightTrace(pos)
    return trace.trace(
        pos,
        pos - Vector(0, 0, Utils.HEIGHT_TRACE_LENGTH),
        PropControl.shouldHitHeightTrace
    )
end

function PropControl.getHeight(tr, pos)
    return pos.z - tr.HitPos.z
end

function PropControl.getTimeToTarget(height, velZ, targetHeight)
    if velZ >= 0 then return math.huge end
    targetHeight = targetHeight or Utils.TARGET_HEIGHT

    local distanceToTarget = math.max(height - targetHeight, 0)

    return distanceToTarget / math.max(-velZ, 1)
end

function PropControl.getInfluence(height, velZ, targetHeight)
    local timeToTarget = PropControl.getTimeToTarget(height, velZ, targetHeight)
    local t = math.clamp(timeToTarget / Utils.LOOKAHEAD_TIME, 0, 1)

    return (1 - t)^Utils.INFLUENCE_FALLOFF_EXPONENT
end

return PropControl
