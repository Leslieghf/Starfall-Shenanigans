local InputControl = {}

local KEY = {
    JUMP = IN_KEY.JUMP,
    FORWARD = IN_KEY.FORWARD,
    BACK = IN_KEY.BACK,
    MOVE_LEFT = IN_KEY.MOVELEFT,
    MOVE_RIGHT = IN_KEY.MOVERIGHT,
    SPEED = IN_KEY.SPEED
}

local function axis(ply, positiveKey, negativeKey)
    local value = 0

    if ply:keyDown(positiveKey) then value = value + 1 end
    if ply:keyDown(negativeKey) then value = value - 1 end

    return value
end

function InputControl.getPilot(propControl)
    local seat = propControl.Registry.seat and propControl.Registry.seat.ent
    local ply = owner()

    if not seat or not seat:isValid() then return nil end
    if not ply or not ply:isValid() or not ply:inVehicle() then return nil end
    if ply:getVehicle() ~= seat then return nil end

    return ply
end

function InputControl.read(propControl)
    local pilot = InputControl.getPilot(propControl)
    if not pilot then
        return {
            active = false,
            throttle = 0,
            yaw = 0,
            jumpDown = false,
            boost = false,
            pilot = nil
        }
    end

    return {
        active = true,
        throttle = axis(pilot, KEY.FORWARD, KEY.BACK),
        yaw = axis(pilot, KEY.MOVE_LEFT, KEY.MOVE_RIGHT),
        jumpDown = pilot:keyDown(KEY.JUMP),
        boost = pilot:keyDown(KEY.SPEED),
        pilot = pilot
    }
end

return InputControl
