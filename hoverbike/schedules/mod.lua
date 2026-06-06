--@include starfall_shenanigans/hoverbike/props/systems.lua
--@include starfall_shenanigans/hoverbike/control/systems.lua
--@include starfall_shenanigans/std/schedules/mod.lua
--@include starfall_shenanigans/hoverbike/schedules/startup/mod.lua
--@include starfall_shenanigans/hoverbike/schedules/think/mod.lua
--@include starfall_shenanigans/hoverbike/schedules/entity_removed/mod.lua
--@include starfall_shenanigans/hoverbike/schedules/player_disconnected/mod.lua
--@include starfall_shenanigans/hoverbike/schedules/player_physics_pickup/mod.lua
--@include starfall_shenanigans/hoverbike/schedules/physgun_pickup/mod.lua
--@include starfall_shenanigans/hoverbike/schedules/physgun_drop/mod.lua

local PropSystems = require("starfall_shenanigans/hoverbike/props/systems.lua")
local ControlSystems = require("starfall_shenanigans/hoverbike/control/systems.lua")
local StdSchedules = require("starfall_shenanigans/std/schedules/mod.lua")

local Schedules = {
    STARTUP = require("starfall_shenanigans/hoverbike/schedules/startup/mod.lua"),
    THINK = require("starfall_shenanigans/hoverbike/schedules/think/mod.lua"),
    ENTITY_REMOVED = require("starfall_shenanigans/hoverbike/schedules/entity_removed/mod.lua"),
    PLAYER_DISCONNECTED = require("starfall_shenanigans/hoverbike/schedules/player_disconnected/mod.lua"),
    PLAYER_PHYSICS_PICKUP = require("starfall_shenanigans/hoverbike/schedules/player_physics_pickup/mod.lua"),
    PHYSGUN_PICKUP = require("starfall_shenanigans/hoverbike/schedules/physgun_pickup/mod.lua"),
    PHYSGUN_DROP = require("starfall_shenanigans/hoverbike/schedules/physgun_drop/mod.lua"),
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
