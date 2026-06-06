--@include mod.lua
--@include ../debug/mod.lua
--@include ../height/mod.lua
--@include ../props/mod.lua

local Control = require("mod.lua")
local Debug = require("../debug/mod.lua")
local Height = require("../height/mod.lua")
local Props = require("../props/mod.lua")

local Systems = {}

local function isControlledBikePart(ent)
    return Control.Manual.isControlledPart(ent, Props)
end

local function resetFlightState()
    Control.AngVel.resetState()
    Control.Drive.resetState()
    Control.Height.resetInputState()
end

local function updateManual()
    local manualControlActive = Control.Manual.isActive()

    if Control.Manual.consumeEndedTransition(manualControlActive) then
        resetFlightState()
    end

    if manualControlActive then
        Debug.Visualizer.cleanup()
        return false
    end
end

local function updateFlight()
    local chipEnt = chip()
    local pos = chipEnt:getPos()
    local vel = chipEnt:getVelocity()
    local totalMass = Props.getMass()
    local totalInertia = Props.getTotalInertia()
    local centerOfMass = Props.getCenterOfMass(chipEnt)
    local input = Control.Input.read(Props)
    local tr = Height.Trace.getTrace(pos)
    local height = Height.Trace.getHeight(tr, pos)
    local targetHeight = Control.Height.update(input, height)
    local appliedForce = Vector()
    local appliedTorque = Vector()
    local gravityForce = Vector()
    local springForce = Vector()
    local dampingForce = Vector()

    if Control.Vel.shouldApplyForce(tr, vel.z) then
        gravityForce = Control.Vel.getGravityCompensationForce(height, vel.z, targetHeight, totalMass)
        springForce = Control.Vel.getSpringForce(height, vel.z, targetHeight, totalMass)
        dampingForce = Control.Vel.getDampingForce(height, vel.z, targetHeight, totalMass)

        appliedForce = Control.Vel.applyForce(
            chipEnt,
            gravityForce,
            springForce,
            dampingForce,
            centerOfMass
        )
    end

    Control.Vel.debugPrint(tr, height, targetHeight, vel.z, totalMass, gravityForce, springForce, dampingForce, appliedForce)

    local driveForce, driveTorque = Control.Drive.apply(chipEnt, input, totalMass, totalInertia, centerOfMass)
    appliedForce = appliedForce + driveForce
    appliedTorque = appliedTorque + driveTorque

    local uprightErrorAxis = Control.AngVel.getUprightErrorAxis(chipEnt, Control.AngVel.TARGET_UP)
    if Control.AngVel.shouldApplyTorque(chipEnt, uprightErrorAxis) then
        appliedTorque = appliedTorque + Control.AngVel.applyTorque(
            chipEnt,
            Control.AngVel.getUprightSpringTorque(chipEnt, totalInertia, uprightErrorAxis),
            Control.AngVel.getUprightIntegralTorque(chipEnt, totalInertia, uprightErrorAxis),
            Control.AngVel.getRotationalDampingTorque(chipEnt, totalInertia)
        )
    end

    Debug.Visualizer.update(appliedForce, appliedTorque)
end

local function clearManual(ent)
    Control.Manual.clear(ent)
end

local function cleanupDebugForRemovedChip(ent)
    if ent == chip() then
        Debug.Visualizer.cleanup()
    end
end

local function clearManualForDisconnectedPlayer(ply)
    Control.Manual.clearAll()
end

local function cleanupDebugForDisconnectedPlayer(ply)
    Debug.Visualizer.cleanup()
end

local function reapplyDecorativeInteractivityBlock(ply, ent)
    if Props.isDecorativeProp(ent) then
        Props.reapplyDecorativeInteractivityBlock(ent)
    end
end

local function startManual(ply, ent)
    if isControlledBikePart(ent) then
        Control.Manual.pickup(ent)
    end
end

local function stopManual(ply, ent)
    if isControlledBikePart(ent) then
        Control.Manual.drop(ent)
    end
end

function Systems.register(Schedules)
    Schedules.register(Schedules.THINK, "control.updateManual", updateManual)
    Schedules.register(Schedules.THINK, "control.updateFlight", updateFlight)
    Schedules.register(Schedules.ENTITY_REMOVED, "control.clearManual", clearManual)
    Schedules.register(Schedules.ENTITY_REMOVED, "debug.cleanupForRemovedChip", cleanupDebugForRemovedChip)
    Schedules.register(Schedules.PLAYER_DISCONNECTED, "control.clearManualForDisconnectedPlayer", clearManualForDisconnectedPlayer)
    Schedules.register(Schedules.PLAYER_DISCONNECTED, "debug.cleanupForDisconnectedPlayer", cleanupDebugForDisconnectedPlayer)
    Schedules.register(Schedules.PLAYER_PHYSICS_PICKUP, "props.reapplyDecorativeInteractivityBlock", reapplyDecorativeInteractivityBlock)
    Schedules.register(Schedules.PHYSGUN_PICKUP, "control.startManual", startManual)
    Schedules.register(Schedules.PHYSGUN_DROP, "control.stopManual", stopManual)
end

return Systems
