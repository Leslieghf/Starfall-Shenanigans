--@include utils.lua

local Utils = require("utils.lua")

local PropControl = {}

PropControl.Registry = {}

function PropControl.startup()
    -- Chip
    local chip = chip()
    PropControl.addPropToRegistry(chip, "chip")

    -- Seat
    local seatPos = chip:getPos() + Vector(0, 0, 11)
    local seatAng = chip:getAngles()
    local seatModel = "models/props_phx/carseat3.mdl"
    local seatFrozen = true
    local seat = prop.createSeat(seatPos, seatAng, seatModel, seatFrozen)
    constraint.weld(seat, chip)
    constraint.keepupright(seat, Angle(90, 0, 0), 0, 0)
    PropControl.addPropToRegistry(seat, "seat")
end

function PropControl.addPropToRegistry(ent, name)
    PropControl.Registry[name] = {ent = ent, mass = ent:getMass()}
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