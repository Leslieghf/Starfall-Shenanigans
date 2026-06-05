--@include rigidbodyControl.lua

local RigidbodyControl = require("rigidbodyControl.lua")

local AngVelControl = {}
AngVelControl.DAMPING_FACTOR = 1.0

local function localVectorToWorld(ent, vec)
    return ent:localToWorld(vec) - ent:getPos()
end

function AngVelControl.getRotationalDampingTorque(ent, propsRegistry)
    local angVel = ent:getAngleVelocity()
    local inertia = RigidbodyControl.getTotalInertia(propsRegistry)
    local localTorque = inertia * angVel * -AngVelControl.DAMPING_FACTOR

    return localVectorToWorld(ent, localTorque)
end

function AngVelControl.applyTotalTorque(ent, propsRegistry)
    local torque = AngVelControl.getRotationalDampingTorque(ent, propsRegistry)
    ent:applyTorque(torque)
    return torque
end

return AngVelControl
