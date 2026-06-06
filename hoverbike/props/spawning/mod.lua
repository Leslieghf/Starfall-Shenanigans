--@include starfall_shenanigans/hoverbike/props/spawning/functions.lua
--@include starfall_shenanigans/hoverbike/props/spawning/types.lua

local Functions = require("starfall_shenanigans/hoverbike/props/spawning/functions.lua")
local Types = require("starfall_shenanigans/hoverbike/props/spawning/types.lua")

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
