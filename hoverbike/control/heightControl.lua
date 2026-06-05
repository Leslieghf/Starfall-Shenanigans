--@include ../utils.lua

local Utils = require("../utils.lua")
local HeightControl = {}

HeightControl.DOUBLE_TAP_WINDOW = 0.3
HeightControl.LOG_RATE = 0.9
HeightControl.LOG_OFFSET = 80
HeightControl.MAX_DT = 0.05

HeightControl.TargetHeight = Utils.TARGET_HEIGHT
HeightControl.FlightEnabled = false
HeightControl.LastJumpTapAt = nil
HeightControl.JumpWasDown = false
HeightControl.LastUpdateAt = nil

local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

local function updateDt()
    local now = timer.curtime()
    local dt = HeightControl.LastUpdateAt and now - HeightControl.LastUpdateAt or 0

    HeightControl.LastUpdateAt = now
    return math.min(dt, HeightControl.MAX_DT)
end

local function currentHeightTarget(height)
    return clamp(
        math.max(height or Utils.TARGET_HEIGHT, Utils.TARGET_HEIGHT),
        Utils.MIN_TARGET_HEIGHT,
        Utils.MAX_TARGET_HEIGHT
    )
end

local function increaseTarget(dt)
    local target = (HeightControl.TargetHeight + HeightControl.LOG_OFFSET) * math.exp(HeightControl.LOG_RATE * dt) - HeightControl.LOG_OFFSET
    HeightControl.TargetHeight = clamp(target, Utils.MIN_TARGET_HEIGHT, Utils.MAX_TARGET_HEIGHT)
end

function HeightControl.resetInputState()
    HeightControl.LastJumpTapAt = nil
    HeightControl.JumpWasDown = false
    HeightControl.LastUpdateAt = nil
end

function HeightControl.resetTarget()
    HeightControl.TargetHeight = Utils.TARGET_HEIGHT
    HeightControl.FlightEnabled = false
end

function HeightControl.enableAt(height)
    HeightControl.TargetHeight = currentHeightTarget(height)
    HeightControl.FlightEnabled = true
end

function HeightControl.toggle(height)
    if HeightControl.FlightEnabled then
        HeightControl.resetTarget()
    else
        HeightControl.enableAt(height)
    end
end

function HeightControl.update(input, height)
    local dt = updateDt()
    local jumpDown = input.active and input.jumpDown
    local now = timer.curtime()

    if jumpDown and not HeightControl.JumpWasDown then
        if HeightControl.LastJumpTapAt and now - HeightControl.LastJumpTapAt <= HeightControl.DOUBLE_TAP_WINDOW then
            HeightControl.toggle(height)
            HeightControl.LastJumpTapAt = nil
        else
            HeightControl.LastJumpTapAt = now
        end
    end

    HeightControl.JumpWasDown = jumpDown

    if HeightControl.FlightEnabled and jumpDown then
        increaseTarget(dt)
    end

    return HeightControl.TargetHeight
end

return HeightControl
