--@include utils.lua

local Utils = require("utils.lua")

local AngVelControl = {}
AngVelControl.DAMPING_FACTOR = 0.01

function AngVelControl.getRotationalDampingTorque(ent)
    local angVel = ent:getAngleVelocity()
    local inertia = ent:getInertia()

    return inertia * angVel * -AngVelControl.DAMPING_FACTOR
end

function AngVelControl.applyTotalTorque(ent)
    local torque = AngVelControl.getRotationalDampingTorque(ent)
    Utils.debugPrint("Applying torque: '" .. tostring(torque) .. "'.")
    ent:applyTorque(torque)
end

return AngVelControl