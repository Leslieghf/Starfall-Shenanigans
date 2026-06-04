local RigidbodyControl = require("rigidbodyControl.lua")

local AngVelControl = {}
AngVelControl.DAMPING_FACTOR = 1.0

function AngVelControl.getRotationalDampingTorque(propsRegistry)
    local angVel = RigidbodyControl.getAverageAngleVelocity(propsRegistry)
    local inertia = RigidbodyControl.getTotalInertia(propsRegistry)

    return inertia * angVel * -AngVelControl.DAMPING_FACTOR
end

function AngVelControl.applyTotalTorque(ent, propsRegistry)
    local torque = AngVelControl.getRotationalDampingTorque(propsRegistry)
    ent:applyTorque(torque)
    return torque
end

return AngVelControl