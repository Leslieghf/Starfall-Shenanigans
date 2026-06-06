--@include functions.lua
--@include types.lua
--@include spawning/mod.lua
--@include registry/mod.lua
--@include physicalProperties/mod.lua
--@include seat/mod.lua
--@include testSphere/mod.lua

local Functions = require("functions.lua")
local Types = require("types.lua")
local Spawning = require("spawning/mod.lua")
local Registry = require("registry/mod.lua")
local PhysicalProperties = require("physicalProperties/mod.lua")
local Seat = require("seat/mod.lua")
local TestSphere = require("testSphere/mod.lua")

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
