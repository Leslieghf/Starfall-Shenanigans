--@include utils.lua

local Utils = require("utils.lua")

local AngVelControl = {}

AngVelControl.ROTATIONAL_DAMPING = 0.1

function AngVelControl.getRotationalDampingTorque(ent)
    local angVel = ent:getAngleVelocity()
    local inertia = ent:getInertia()
    local timeStep = timer.frametime()
    return -AngVelControl.ROTATIONAL_DAMPING * ((inertia * angVel) / timeStep)
end


function AngVelControl.applyTotalTorque(ent, dampingTorque)
    local torque = dampingTorque
    ent:applyTorque(torque)
end

return AngVelControl