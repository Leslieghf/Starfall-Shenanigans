--@include ../functions.lua
--@include types.lua

local PropFunctions = require("../functions.lua")
local TestSphereTypes = require("types.lua")

local TestSphereFunctions = {}

local function randomUpperSphereDirection()
    local minZ = math.cos(math.rad(TestSphereTypes.MAX_POLAR_DEGREES))
    local z = minZ + math.random() * (1 - minZ)
    local phi = math.random() * math.pi * 2
    local xy = math.sqrt(1 - z * z)

    return Vector(math.cos(phi) * xy, math.sin(phi) * xy, z)
end

function TestSphereFunctions.spawn(chipEnt)
    local center = chipEnt:getPos()
    local ang = chipEnt:getAngles()

    for i = 1, TestSphereTypes.COUNT do
        local direction = randomUpperSphereDirection()
        local pos = center + direction * TestSphereTypes.RADIUS

        PropFunctions.spawnDecorativeProp(
            pos,
            ang,
            TestSphereTypes.MODEL,
            false,
            chipEnt
        )
    end
end

return TestSphereFunctions
