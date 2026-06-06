--@include starfall_shenanigans/hoverbike/props/registry/types.lua

local RegistryTypes = require("starfall_shenanigans/hoverbike/props/registry/types.lua")

local RegistryFunctions = {}

local function makeDecorativeUninteractable(ent)
    ent:disablePhysgun(true)
    ent:setFrozen(true)
end

function RegistryFunctions.registerPhysicalProp(ent, name)
    RegistryTypes.PhysicalProps[name] = {ent = ent}
    return ent
end

function RegistryFunctions.getPhysicalProp(name)
    local physicalProp = RegistryTypes.PhysicalProps[name]
    if not physicalProp then return nil end

    return physicalProp.ent
end

function RegistryFunctions.isPhysicalProp(ent)
    for _, physicalProp in pairs(RegistryTypes.PhysicalProps) do
        if ent == physicalProp.ent then return true end
    end

    return false
end

function RegistryFunctions.registerDecorativeProp(ent)
    makeDecorativeUninteractable(ent)
    table.insert(RegistryTypes.DecorativeProps, ent)
    return ent
end

function RegistryFunctions.isDecorativeProp(ent)
    for _, decorativeProp in ipairs(RegistryTypes.DecorativeProps) do
        if ent == decorativeProp then return true end
    end

    return false
end

function RegistryFunctions.reapplyDecorativeInteractivityBlock(ent)
    makeDecorativeUninteractable(ent)
end

return RegistryFunctions
