--@include starfall_shenanigans/hoverbike/props/test_sphere/functions.lua
--@include starfall_shenanigans/hoverbike/props/test_sphere/types.lua

local Functions = require("starfall_shenanigans/hoverbike/props/test_sphere/functions.lua")
local Types = require("starfall_shenanigans/hoverbike/props/test_sphere/types.lua")

local TestSphere = {
    Functions = Functions,
    Types = Types
}

TestSphere.spawn = Functions.spawn

return TestSphere
