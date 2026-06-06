--@include starfall_shenanigans/hoverbike/constants.lua

local Constants = require("starfall_shenanigans/hoverbike/constants.lua")

local LogFunctions = {}
local printTimers = {}

function LogFunctions.debugPrint(message)
    local interval = Constants.DEBUG_PRINT_INTERVAL
    local key = tostring(interval)
    local timer = printTimers[key] or 0

    timer = timer + 1
    if timer >= interval then
        print(message)
        timer = 0
    end

    printTimers[key] = timer
end

return LogFunctions
