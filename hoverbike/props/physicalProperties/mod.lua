--@include functions.lua
--@include types.lua

local Functions = require("functions.lua")
local Types = require("types.lua")

local PhysicalProperties = {
    Functions = Functions,
    Types = Types
}

PhysicalProperties.refreshIfNeeded = Functions.refreshIfNeeded
PhysicalProperties.invalidate = Functions.invalidate
PhysicalProperties.get = Functions.get
PhysicalProperties.getMass = Functions.getMass
PhysicalProperties.getTotalInertia = Functions.getTotalInertia
PhysicalProperties.getCenterOfMass = Functions.getCenterOfMass

return PhysicalProperties
