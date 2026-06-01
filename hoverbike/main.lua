--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl

local TARGET_HEIGHT = 100

local SPRING = 5
local DAMPING = 1.5

local BASE_GRAVITY = 9.01352

local counter = 0
local log_delay = 60

hook.add("think", "hover", function()

    local ent = chip()

    local pos = ent:getPos()
    local vel = ent:getVelocity()
    local mass = ent:getMass()

    local tr = trace.trace(
        pos - Vector(0, 0, 8),
        pos - Vector(0, 0, TARGET_HEIGHT * 4)
    )

    local springForce = Vector()

    if tr.Hit then

        local height =
            pos.z - tr.HitPos.z

        local error =
            TARGET_HEIGHT - height

        springForce =
            Vector(0, 0, error * SPRING * mass)

        if (counter % log_delay) == 0 then
            print(
                string.format(
                    "[Hoverbike] height=%.2f error=%.2f vz=%.2f",
                    height,
                    error,
                    vel.z
                )
            )
        end
    end

    local gravityCompensation = Vector(0, 0, mass * BASE_GRAVITY)

    local dampingForce =
        Vector(0, 0, -vel.z * DAMPING * mass)

    if tr.Hit then
        ent:applyForceCenter(
            gravityCompensation
            + springForce
            + dampingForce
        )
    end

    counter = counter + 1

end)