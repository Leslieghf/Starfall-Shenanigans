--@include ../../../std/pipeline/mod.lua

local Pipeline = require("../../../std/pipeline/mod.lua")

local SpawningTypes = {}

SpawningTypes.SpawnPipeline = Pipeline.newPipeline("prop_spawns")

return SpawningTypes
