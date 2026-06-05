--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl
--@include propControl.lua
--@include rigidbodyControl.lua
--@include velControl.lua
--@include angvelControl.lua
--@include gizmoCore.lua
--@include gizmoLinArrow.lua
--@include gizmoAngArrow.lua
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
    local tr = PropControl.getHeightTrace(pos)
    local height = PropControl.getHeight(tr, pos)
    local appliedForce = Vector()
    local appliedTorque = AngVelControl.applyTotalTorque(ent, PropControl.Registry)

    if VelControl.shouldApplyForce(tr, vel.z) then
        appliedForce = VelControl.applyForce(
            ent,
            PropControl.Registry,
            VelControl.getGravityCompensationForce(height, vel.z, totalMass),
            VelControl.getSpringForce(height, vel.z, totalMass),
            VelControl.getDampingForce(height, vel.z, totalMass)
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
