--@include utils.lua

local Utils = require("utils.lua")

local AngVelControl = {}

AngVelControl.ROTATIONAL_DAMPING = 0.01

function AngVelControl.getRotationalDampingTorque(ent)

    local angVel = ent:getAngleVelocity()
    local inertia = ent:getInertia()

    return Vector(
        -angVel.x * inertia.x,
        -angVel.y * inertia.y,
        -angVel.z * inertia.z
    ) * AngVelControl.ROTATIONAL_DAMPING

end


function AngVelControl.applyTotalTorque(ent, dampingTorque)
    local torque = dampingTorque
    ent:applyTorque(torque)
end

return AngVelControl