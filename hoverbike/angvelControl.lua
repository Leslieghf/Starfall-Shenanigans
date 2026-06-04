local AngVelControl = {}
AngVelControl.DAMPING_FACTOR = 1.0

function AngVelControl.getRotationalDampingTorque(ent)
    local angVel = ent:getAngleVelocity()
    return angVel * -AngVelControl.DAMPING_FACTOR
end

function AngVelControl.applyTotalTorque(ent)
    local torque = AngVelControl.getRotationalDampingTorque(ent)
    ent:applyTorque(torque)
end

return AngVelControl