--@include functions.lua
--@include types.lua

local Functions = require("functions.lua")
local Types = require("types.lua")

local TestSphere = {
    Functions = Functions,
    Types = Types
}

TestSphere.spawn = Functions.spawn

return TestSphere
