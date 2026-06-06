--@include starfall_shenanigans/hoverbike/constants.lua
--@include starfall_shenanigans/hoverbike/props/registry/mod.lua

local Constants = require("starfall_shenanigans/hoverbike/constants.lua")
local PropRegistry = require("starfall_shenanigans/hoverbike/props/registry/mod.lua")

local TraceFunctions = {}

function TraceFunctions.shouldHit(ent)
    if PropRegistry.isPhysicalProp(ent) then return false end
    if PropRegistry.isDecorativeProp(ent) then return false end
    if ent:isPlayer() or ent:isWeapon() or ent:isNPC() or ent:isVehicle() or ent:isNextBot() then return false end

    return true
end

function TraceFunctions.getTrace(pos)
    return trace.trace(
        pos,
        pos - Vector(0, 0, Constants.HEIGHT_TRACE_LENGTH),
        TraceFunctions.shouldHit
    )
end

function TraceFunctions.getHeight(tr, pos)
    return pos.z - tr.HitPos.z
end

function TraceFunctions.getTimeToTarget(height, velZ, targetHeight)
    if velZ >= 0 then return math.huge end
    targetHeight = targetHeight or Constants.TARGET_HEIGHT

    local distanceToTarget = math.max(height - targetHeight, 0)

    return distanceToTarget / math.max(-velZ, 1)
end

function TraceFunctions.getInfluence(height, velZ, targetHeight)
    local timeToTarget = TraceFunctions.getTimeToTarget(height, velZ, targetHeight)
    local t = math.clamp(timeToTarget / Constants.LOOKAHEAD_TIME, 0, 1)

    return (1 - t)^Constants.INFLUENCE_FALLOFF_EXPONENT
end

return TraceFunctions
