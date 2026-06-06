--@include starfall_shenanigans/std/pipeline/mod.lua

local Pipeline = require("starfall_shenanigans/std/pipeline/mod.lua")

local SpawningTypes = {}

SpawningTypes.SpawnPipeline = Pipeline.newPipeline("prop_spawns")

return SpawningTypes
