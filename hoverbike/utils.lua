local Utils = {}

Utils.STARTUP_DONE = false
Utils.BASE_GRAVITY = 9.01352
Utils.TARGET_HEIGHT = 100
Utils.INFLUENCE_FALLOFF_EXPONENT = 4
Utils.LOOKAHEAD_TIME = 0.5

function Utils.isNotChip(ent)
    return ent ~= chip()
end

function Utils.getHeightTrace(pos)
    return trace.trace(
        pos,
        pos - Vector(0, 0, Utils.TARGET_HEIGHT * 4),
        Utils.isNotChip
    )
end

function Utils.getHeight(tr, pos)
    return pos.z - tr.HitPos.z
end

function Utils.getTimeToTarget(height, velZ)
    if velZ >= 0 then return math.huge end

    local distanceToTarget = math.max(height - Utils.TARGET_HEIGHT, 0)

    return distanceToTarget / math.max(-velZ, 1)
end

function Utils.getInfluence(height, velZ)
    local timeToTarget = Utils.getTimeToTarget(height, velZ)
    local t = math.clamp(timeToTarget / Utils.LOOKAHEAD_TIME, 0, 1)

    return (1 - t)^Utils.INFLUENCE_FALLOFF_EXPONENT
end

return Utils