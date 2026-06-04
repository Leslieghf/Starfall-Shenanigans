local Utils = {}

Utils.STARTUP_DONE = false
Utils.BASE_GRAVITY = 9.01352
Utils.TARGET_HEIGHT = 100
Utils.INFLUENCE_FALLOFF_EXPONENT = 4
Utils.LOOKAHEAD_TIME = 0.5
Utils.DEBUG_PRINT_INTERVAL = 15

Utils.debugPrintTimers = {}

function Utils.formatVec(v, precision)
    local fmt = string.format("(%%.%df, %%.%df, %%.%df)", precision, precision, precision)
    return string.format(fmt, v.x, v.y, v.z)
end

function Utils.debugPrint(message)
    local interval = Utils.DEBUG_PRINT_INTERVAL
    local key = tostring(interval)
    local timer = Utils.debugPrintTimers[key] or 0

    timer = timer + 1
    if timer >= interval then
        print(message)
        timer = 0
    end

    Utils.debugPrintTimers[key] = timer
end

return Utils