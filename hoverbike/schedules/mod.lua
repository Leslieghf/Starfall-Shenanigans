--@include ../props/systems.lua
--@include ../control/systems.lua
--@include ../../std/schedules/mod.lua
--@include startup/mod.lua
--@include think/mod.lua
--@include entityRemoved/mod.lua
--@include playerDisconnected/mod.lua
--@include playerPhysicsPickup/mod.lua
--@include physgunPickup/mod.lua
--@include physgunDrop/mod.lua

local PropSystems = require("../props/systems.lua")
local ControlSystems = require("../control/systems.lua")
local StdSchedules = require("../../std/schedules/mod.lua")

local Schedules = {
    STARTUP = require("startup/mod.lua"),
    THINK = require("think/mod.lua"),
    ENTITY_REMOVED = require("entityRemoved/mod.lua"),
    PLAYER_DISCONNECTED = require("playerDisconnected/mod.lua"),
    PLAYER_PHYSICS_PICKUP = require("playerPhysicsPickup/mod.lua"),
    PHYSGUN_PICKUP = require("physgunPickup/mod.lua"),
    PHYSGUN_DROP = require("physgunDrop/mod.lua"),
    initialized = false
}

Schedules.THINK.startupSchedule = Schedules.STARTUP

function Schedules.register(schedule, systemName, run)
    StdSchedules.registerSystem(schedule, systemName, run)
end

function Schedules.installSystems()
    if Schedules.initialized then return end

    PropSystems.register(Schedules)
    ControlSystems.register(Schedules)
    Schedules.initialized = true
end

function Schedules.runThink()
    Schedules.THINK.run()
end

function Schedules.runEntityRemoved(ent)
    Schedules.ENTITY_REMOVED.run(ent)
end

function Schedules.runPlayerDisconnected(ply)
    Schedules.PLAYER_DISCONNECTED.run(ply)
end

function Schedules.runPlayerPhysicsPickup(ply, ent)
    Schedules.PLAYER_PHYSICS_PICKUP.run(ply, ent)
end

function Schedules.runPhysgunPickup(ply, ent)
    Schedules.PHYSGUN_PICKUP.run(ply, ent)
end

function Schedules.runPhysgunDrop(ply, ent)
    Schedules.PHYSGUN_DROP.run(ply, ent)
end

return Schedules
