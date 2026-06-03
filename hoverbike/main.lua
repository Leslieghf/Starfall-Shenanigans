--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl
--@include utils.lua
--@include velControl.lua
--@include angVelControl.lua

local Utils = require("utils.lua")
local VelControl = require("velControl.lua")
local AngVelControl = require("angVelControl.lua")

local Props = {}

local function startup()
    local ent = chip()
    local pos = ent:getPos()
    local ang = ent:getAngles()
    local model = "models/props_phx/carseat3.mdl"
    local frozen = true

    Props.seat = prop.createSeat(pos + Vector(0, 0, 11), ang, model, frozen)
    constraint.weld(Props.seat, ent)
end

local function update()
    local ent = chip()
    local pos = ent:getPos()
    local vel = ent:getVelocity()
    local mass = ent:getMass()
    local tr = Utils.getHeightTrace(pos)
    local height = Utils.getHeight(tr, pos)

    if VelControl.shouldApplyTotalForce(tr, vel.z) then
        VelControl.applyTotalForce(
            ent,
            VelControl.getGravityCompensationForce(height, vel.z, mass),
            VelControl.getSpringForce(height, vel.z, mass),
            VelControl.getDampingForce(height, vel.z, mass)
        )
    end
    
    -- AngVelControl.applyTotalTorque(ent, getRotationalDampingTorque(ent))
end

hook.add("Think", "update", function()
    if not STARTUP_DONE then
        startup()
        STARTUP_DONE = true
    end
    
    update()
end)