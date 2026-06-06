--@include types.lua

local SpawningTypes = require("types.lua")

local SpawningFunctions = {}

function SpawningFunctions.spawn(pos, ang, model, frozen, complete)
    SpawningTypes.SpawnPipeline:enqueue(
        function()
            return prop.create(pos, ang, model, frozen)
        end,
        complete
    )
end

function SpawningFunctions.spawnSeat(pos, ang, model, frozen, complete)
    SpawningTypes.SpawnPipeline:enqueue(
        function()
            return prop.createSeat(pos, ang, model, frozen)
        end,
        complete
    )
end

function SpawningFunctions.update()
    return SpawningTypes.SpawnPipeline:processWhile(prop.canSpawn)
end

function SpawningFunctions.size()
    return SpawningTypes.SpawnPipeline:size()
end

return SpawningFunctions
