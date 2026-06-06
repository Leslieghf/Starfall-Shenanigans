--@include starfall_shenanigans/std/cache/mod.lua
--@include starfall_shenanigans/hoverbike/constants.lua
--@include starfall_shenanigans/hoverbike/props/registry/mod.lua
--@include starfall_shenanigans/hoverbike/props/physical_properties/types.lua

local Cache = require("starfall_shenanigans/std/cache/mod.lua")
local Constants = require("starfall_shenanigans/hoverbike/constants.lua")
local Registry = require("starfall_shenanigans/hoverbike/props/registry/mod.lua")
local PhysicalPropertiesTypes = require("starfall_shenanigans/hoverbike/props/physical_properties/types.lua")

local PhysicalPropertiesFunctions = {}

local function build(chipEnt)
    local totalMass = 0
    local totalInertia = Vector()
    local weightedLocalPos = Vector()

    for _, physicalProp in pairs(Registry.PhysicalProps) do
        local ent = physicalProp.ent
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

if not PhysicalPropertiesTypes.Cache then
    PhysicalPropertiesTypes.Cache = Cache.newCache(
        build,
        Constants.PHYSICAL_PROPERTIES_REFRESH_INTERVAL
    )
end

function PhysicalPropertiesFunctions.refreshIfNeeded(chipEnt)
    if PhysicalPropertiesTypes.Cache:shouldRefresh() then
        PhysicalPropertiesTypes.Cache:refresh(chipEnt)
    end
end

function PhysicalPropertiesFunctions.invalidate()
    PhysicalPropertiesTypes.Cache:invalidate()
end

function PhysicalPropertiesFunctions.get()
    return PhysicalPropertiesTypes.Cache:get()
end

function PhysicalPropertiesFunctions.getMass()
    return PhysicalPropertiesFunctions.get().mass
end

function PhysicalPropertiesFunctions.getTotalInertia()
    return PhysicalPropertiesFunctions.get().inertia
end

function PhysicalPropertiesFunctions.getCenterOfMass(chipEnt)
    local localCenterOfMass = PhysicalPropertiesFunctions.get().localCenterOfMass
    if not localCenterOfMass then return nil end

    return chipEnt:localToWorld(localCenterOfMass)
end

return PhysicalPropertiesFunctions
