--@include starfall_shenanigans/hoverbike/props/spawning/mod.lua
--@include starfall_shenanigans/hoverbike/props/registry/mod.lua
--@include starfall_shenanigans/hoverbike/props/physical_properties/mod.lua

local Spawning = require("starfall_shenanigans/hoverbike/props/spawning/mod.lua")
local Registry = require("starfall_shenanigans/hoverbike/props/registry/mod.lua")
local PhysicalProperties = require("starfall_shenanigans/hoverbike/props/physical_properties/mod.lua")

local PropFunctions = {}

function PropFunctions.update(chipEnt)
    Spawning.update()
    PhysicalProperties.refreshIfNeeded(chipEnt)
end

function PropFunctions.registerPhysicalProp(ent, name)
    Registry.registerPhysicalProp(ent, name)
    PhysicalProperties.invalidate()
    return ent
end

function PropFunctions.registerDecorativeProp(ent)
    return Registry.registerDecorativeProp(ent)
end

function PropFunctions.spawnDecorativeProp(pos, ang, model, frozen, parentEnt, complete)
    Spawning.spawn(pos, ang, model, frozen, function(ent)
        if parentEnt then
            ent:setParent(parentEnt)
        end

        PropFunctions.registerDecorativeProp(ent)

        if complete then
            complete(ent)
        end
    end)
end

function PropFunctions.spawnPhysicalProp(pos, ang, model, frozen, name, configure, complete)
    Spawning.spawn(pos, ang, model, frozen, function(ent)
        if configure then
            configure(ent)
        end

        PropFunctions.registerPhysicalProp(ent, name)

        if complete then
            complete(ent)
        end
    end)
end

function PropFunctions.spawnSeat(pos, ang, model, frozen, name, configure, complete)
    Spawning.spawnSeat(pos, ang, model, frozen, function(seat)
        if configure then
            configure(seat)
        end

        PropFunctions.registerPhysicalProp(seat, name)

        if complete then
            complete(seat)
        end
    end)
end

function PropFunctions.getPhysicalProp(name)
    return Registry.getPhysicalProp(name)
end

function PropFunctions.isPhysicalProp(ent)
    return Registry.isPhysicalProp(ent)
end

function PropFunctions.isDecorativeProp(ent)
    return Registry.isDecorativeProp(ent)
end

function PropFunctions.reapplyDecorativeInteractivityBlock(ent)
    Registry.reapplyDecorativeInteractivityBlock(ent)
end

function PropFunctions.getPhysicalProperties()
    return PhysicalProperties.get()
end

function PropFunctions.getMass()
    return PhysicalProperties.getMass()
end

function PropFunctions.getTotalInertia()
    return PhysicalProperties.getTotalInertia()
end

function PropFunctions.getCenterOfMass(chipEnt)
    return PhysicalProperties.getCenterOfMass(chipEnt)
end

return PropFunctions
