--@include utils.lua

local Utils = require("utils.lua")

local PropControl = {}

PropControl.Registry = {}

function PropControl.startup()
    local ent = chip()
    local pos = ent:getPos()
    local ang = ent:getAngles()
    local model = "models/props_phx/carseat3.mdl"
    local frozen = true

    local seat = prop.createSeat(pos + Vector(0, 0, 11), ang, model, frozen)
    constraint.weld(seat, ent)
    
    PropControl.addPropToRegistry(ent, "chip")
    PropControl.addPropToRegistry(seat, "seat")
end

function PropControl.addPropToRegistry(ent, name)
    PropControl.Registry[name] = {ent = ent, mass = ent:getMass()}
    -- print("Added prop '" .. name .. "' to registry with a mass of " .. ent:getMass())
end

function PropControl.isIgnoredProp(ent)
    for _, data in pairs(PropControl.Registry) do
        if ent == data.ent then return false end
    end

    return true
end

function PropControl.getHeightTrace(pos)
    return trace.trace(
        pos,
        pos - Vector(0, 0, Utils.TARGET_HEIGHT * 4),
        PropControl.isIgnoredProp
    )
end

function PropControl.getHeight(tr, pos)
    return pos.z - tr.HitPos.z
end

function PropControl.getTimeToTarget(height, velZ)
    if velZ >= 0 then return math.huge end

    local distanceToTarget = math.max(height - Utils.TARGET_HEIGHT, 0)

    return distanceToTarget / math.max(-velZ, 1)
end

function PropControl.getInfluence(height, velZ)
    local timeToTarget = PropControl.getTimeToTarget(height, velZ)
    local t = math.clamp(timeToTarget / Utils.LOOKAHEAD_TIME, 0, 1)

    return (1 - t)^Utils.INFLUENCE_FALLOFF_EXPONENT
end

return PropControl