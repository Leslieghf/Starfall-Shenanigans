--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl
--@include propControl.lua
--@include rigidbodyControl.lua
--@include velControl.lua
--@include angvelControl.lua
--@include debugDraw.lua
--@include debugLinArrow.lua
--@include debugAngArrow.lua
--@include debugVisualizer.lua

local PropControl = require("propControl.lua")
local RigidbodyControl = require("rigidbodyControl.lua")
local VelControl = require("velControl.lua")
local AngVelControl = require("angvelControl.lua")
local DebugVisualizer = require("debugVisualizer.lua")

local function startup()
    PropControl.startup()
end

local function update()
    local ent = chip()
    local pos = ent:getPos()
    local vel = ent:getVelocity()
    local totalMass = RigidbodyControl.getMass(PropControl.Registry)
    local totalInertia = RigidbodyControl.getTotalInertia(PropControl.Registry)
    local tr = PropControl.getHeightTrace(pos)
    local height = PropControl.getHeight(tr, pos)
    local appliedForce = Vector()
    local appliedTorque = Vector()

    if VelControl.shouldApplyForce(tr, vel.z) then
        appliedForce = VelControl.applyForce(
            ent,
            PropControl.Registry,
            VelControl.getGravityCompensationForce(height, vel.z, totalMass),
            VelControl.getSpringForce(height, vel.z, totalMass),
            VelControl.getDampingForce(height, vel.z, totalMass)
        )
    end

    local uprightErrorAxis = AngVelControl.getUprightErrorAxis(ent, AngVelControl.TARGET_UP)
    if AngVelControl.shouldApplyTorque(ent, uprightErrorAxis) then
        appliedTorque = AngVelControl.applyTorque(
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
    if ent == chip() then
        DebugVisualizer.cleanup()
    end
end)
