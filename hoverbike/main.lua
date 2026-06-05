--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl
--@include control/propControl.lua
--@include control/rigidbodyControl.lua
--@include control/velControl.lua
--@include control/angvelControl.lua
--@include control/manualControl.lua
--@include control/inputControl.lua
--@include control/heightControl.lua
--@include control/driveControl.lua
--@include debug/debugDraw.lua
--@include debug/debugLinArrow.lua
--@include debug/debugAngArrow.lua
--@include debug/debugVisualizer.lua

local PropControl = require("control/propControl.lua")
local RigidbodyControl = require("control/rigidbodyControl.lua")
local VelControl = require("control/velControl.lua")
local AngVelControl = require("control/angvelControl.lua")
local ManualControl = require("control/manualControl.lua")
local InputControl = require("control/inputControl.lua")
local HeightControl = require("control/heightControl.lua")
local DriveControl = require("control/driveControl.lua")
local DebugVisualizer = require("debug/debugVisualizer.lua")

local function startup()
    PropControl.startup()
end

local function update()
    local ent = chip()
    local manualControlActive = ManualControl.isActive()

    if ManualControl.consumeEndedTransition(manualControlActive) then
        AngVelControl.resetState()
        DriveControl.resetState()
        HeightControl.resetInputState()
    end

    if manualControlActive then
        DebugVisualizer.cleanup()
        return
    end

    local pos = ent:getPos()
    local vel = ent:getVelocity()
    local totalMass = RigidbodyControl.getMass(PropControl.Registry)
    local totalInertia = RigidbodyControl.getTotalInertia(PropControl.Registry)
    local input = InputControl.read(PropControl)
    local tr = PropControl.getHeightTrace(pos)
    local height = PropControl.getHeight(tr, pos)
    local targetHeight = HeightControl.update(input, height)
    local appliedForce = Vector()
    local appliedTorque = Vector()
    local gravityForce = Vector()
    local springForce = Vector()
    local dampingForce = Vector()

    if VelControl.shouldApplyForce(tr, vel.z) then
        gravityForce = VelControl.getGravityCompensationForce(height, vel.z, targetHeight, totalMass)
        springForce = VelControl.getSpringForce(height, vel.z, targetHeight, totalMass)
        dampingForce = VelControl.getDampingForce(height, vel.z, targetHeight, totalMass)

        appliedForce = VelControl.applyForce(
            ent,
            PropControl.Registry,
            gravityForce,
            springForce,
            dampingForce
        )
    end

    VelControl.debugPrint(tr, height, targetHeight, vel.z, totalMass, gravityForce, springForce, dampingForce, appliedForce)

    local driveForce, driveTorque = DriveControl.apply(ent, PropControl.Registry, input, totalMass, totalInertia)
    appliedForce = appliedForce + driveForce
    appliedTorque = appliedTorque + driveTorque

    local uprightErrorAxis = AngVelControl.getUprightErrorAxis(ent, AngVelControl.TARGET_UP)
    if AngVelControl.shouldApplyTorque(ent, uprightErrorAxis) then
        appliedTorque = appliedTorque + AngVelControl.applyTorque(
            ent,
            AngVelControl.getUprightSpringTorque(ent, totalInertia, uprightErrorAxis),
            AngVelControl.getUprightIntegralTorque(ent, totalInertia, uprightErrorAxis),
            AngVelControl.getRotationalDampingTorque(ent, totalInertia)
        )
    end
    
    DebugVisualizer.update(appliedForce, appliedTorque)
end

hook.add("Think", "update", function()
    if not STARTUP_DONE then
        startup()
        STARTUP_DONE = true
    end
    
    update()
end)

hook.add("EntityRemoved", "HoverbikeCleaning", function(ent)
    ManualControl.clear(ent)

    if ent == chip() then
        DebugVisualizer.cleanup()
    end
end)

local function isControlledBikePart(ent)
    return ManualControl.isControlledPart(ent, PropControl)
end

hook.add("OnPhysgunPickup", "HoverbikePhysgunPickup", function(ply, ent)
    if isControlledBikePart(ent) then
        ManualControl.pickup(ent)
    end
end)

hook.add("PhysgunDrop", "HoverbikePhysgunDrop", function(ply, ent)
    if isControlledBikePart(ent) then
        ManualControl.drop(ent)
    end
end)

hook.add("PlayerDisconnected", "HoverbikePhysgunDisconnect", function(ply)
    ManualControl.clearAll()
    DebugVisualizer.cleanup()
end)
