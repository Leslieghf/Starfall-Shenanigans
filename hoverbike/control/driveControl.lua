--@include rigidbodyControl.lua

local RigidbodyControl = require("rigidbodyControl.lua")
local DriveControl = {}

DriveControl.FORWARD_ACCEL = 45
DriveControl.VERTICAL_ACCEL = 25
DriveControl.BOOST_MULTIPLIER = 1.75
DriveControl.YAW_FACTOR = 800
DriveControl.MIN_FORCE = 0.001
DriveControl.MIN_TORQUE = 0.001
DriveControl.MAX_DT = 0.05
DriveControl.LastTorqueAt = nil

local function magnitude(vec)
    return math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
end

local function localVectorToWorld(ent, vec)
    return ent:localToWorld(vec) - ent:getPos()
end

local function localInertiaTorqueToWorld(ent, inertia, localAxis, factor)
    return localVectorToWorld(ent, inertia * localAxis * factor)
end

local function torqueDt()
    local now = timer.curtime()
    local dt = DriveControl.LastTorqueAt and now - DriveControl.LastTorqueAt or 0

    DriveControl.LastTorqueAt = now
    return math.min(dt, DriveControl.MAX_DT)
end

function DriveControl.resetState()
    DriveControl.LastTorqueAt = nil
end

function DriveControl.getForce(ent, input, mass)
    if not input.active then return Vector() end

    local boost = input.boost and DriveControl.BOOST_MULTIPLIER or 1
    local localForce = Vector(input.throttle * DriveControl.FORWARD_ACCEL * mass * boost, 0, 0)
    local verticalForce = Vector(0, 0, input.lift * DriveControl.VERTICAL_ACCEL * mass)

    return localVectorToWorld(ent, localForce) + verticalForce
end

function DriveControl.getYawTorque(ent, input, inertia)
    if not input.active then return Vector() end

    local localYawAxis = Vector(0, 0, input.yaw)
    if magnitude(localYawAxis) <= DriveControl.MIN_TORQUE then return Vector() end

    return localInertiaTorqueToWorld(ent, inertia, localYawAxis, DriveControl.YAW_FACTOR) * torqueDt()
end

function DriveControl.apply(ent, propsRegistry, input, mass, inertia)
    local force = DriveControl.getForce(ent, input, mass)
    local torque = DriveControl.getYawTorque(ent, input, inertia)

    if magnitude(force) > DriveControl.MIN_FORCE then
        ent:applyForceOffset(force, RigidbodyControl.getCenterOfMass(ent, propsRegistry))
    end

    if magnitude(torque) > DriveControl.MIN_TORQUE then
        ent:applyTorque(torque)
    end

    return force, torque
end

return DriveControl
