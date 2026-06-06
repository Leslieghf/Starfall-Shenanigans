--@include starfall_shenanigans/hoverbike/props/functions.lua
--@include starfall_shenanigans/hoverbike/props/types.lua
--@include starfall_shenanigans/hoverbike/props/spawning/mod.lua
--@include starfall_shenanigans/hoverbike/props/registry/mod.lua
--@include starfall_shenanigans/hoverbike/props/physical_properties/mod.lua
--@include starfall_shenanigans/hoverbike/props/seat/mod.lua
--@include starfall_shenanigans/hoverbike/props/test_sphere/mod.lua

local Functions = require("starfall_shenanigans/hoverbike/props/functions.lua")
local Types = require("starfall_shenanigans/hoverbike/props/types.lua")
local Spawning = require("starfall_shenanigans/hoverbike/props/spawning/mod.lua")
local Registry = require("starfall_shenanigans/hoverbike/props/registry/mod.lua")
local PhysicalProperties = require("starfall_shenanigans/hoverbike/props/physical_properties/mod.lua")
local Seat = require("starfall_shenanigans/hoverbike/props/seat/mod.lua")
local TestSphere = require("starfall_shenanigans/hoverbike/props/test_sphere/mod.lua")

local Props = {
    Functions = Functions,
    Types = Types,
    Spawning = Spawning,
    Registry = Registry,
    PhysicalProperties = PhysicalProperties,
    Seat = Seat,
    TestSphere = TestSphere,
    PhysicalRegistry = Registry.PhysicalProps,
    DecorativeRegistry = Registry.DecorativeProps,
    SpawnPipeline = Spawning.SpawnPipeline
}

Props.update = Functions.update
Props.registerPhysicalProp = Functions.registerPhysicalProp
Props.registerDecorativeProp = Functions.registerDecorativeProp
Props.spawnDecorativeProp = Functions.spawnDecorativeProp
Props.spawnPhysicalProp = Functions.spawnPhysicalProp
Props.spawnSeat = Functions.spawnSeat
Props.getPhysicalProp = Functions.getPhysicalProp
Props.isPhysicalProp = Functions.isPhysicalProp
Props.isDecorativeProp = Functions.isDecorativeProp
Props.reapplyDecorativeInteractivityBlock = Functions.reapplyDecorativeInteractivityBlock
Props.getPhysicalProperties = Functions.getPhysicalProperties
Props.getMass = Functions.getMass
Props.getTotalInertia = Functions.getTotalInertia
Props.getCenterOfMass = Functions.getCenterOfMass

return Props
