--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl
--@include propControl.lua
--@include rigidbodyControl.lua
--@include velControl.lua
--@include gizmoCore.lua
--@include gizmoLinArrow.lua
--@include gizmoAngArrow.lua
--@include debugVisualizer.lua

local PropControl = require("propControl.lua")
local RigidbodyControl = require("rigidbodyControl.lua")
local VelControl = require("velControl.lua")
local DebugVisualizer = require("debugVisualizer.lua")

local function startup()
    PropControl.startup()
end

local function update()
    local ent = chip()
    local pos = ent:getPos()
    local vel = ent:getVelocity()
    local angVel = ent:getAngleVelocity()
    local totalMass = RigidbodyControl.getMass(PropControl.Registry)
    local tr = PropControl.getHeightTrace(pos)
    local height = PropControl.getHeight(tr, pos)

    if VelControl.shouldApplyForce(tr, vel.z) then
        VelControl.applyForce(
            ent,
            PropControl.Registry,
            VelControl.getGravityCompensationForce(height, vel.z, totalMass),
            VelControl.getSpringForce(height, vel.z, totalMass),
            VelControl.getDampingForce(height, vel.z, totalMass)
        )
    end
    
    DebugVisualizer.update(vel, angVel)
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
