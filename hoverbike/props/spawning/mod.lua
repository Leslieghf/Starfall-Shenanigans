--@include functions.lua
--@include types.lua

local Functions = require("functions.lua")
local Types = require("types.lua")

local Spawning = {
    Functions = Functions,
    Types = Types,
    SpawnPipeline = Types.SpawnPipeline
}

Spawning.spawn = Functions.spawn
Spawning.spawnSeat = Functions.spawnSeat
Spawning.update = Functions.update
Spawning.size = Functions.size

return Spawning
