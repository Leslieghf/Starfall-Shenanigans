--@include functions.lua
--@include types.lua

local Functions = require("functions.lua")
local Types = require("types.lua")

local Registry = {
    Functions = Functions,
    Types = Types,
    PhysicalProps = Types.PhysicalProps,
    DecorativeProps = Types.DecorativeProps
}

Registry.registerPhysicalProp = Functions.registerPhysicalProp
Registry.getPhysicalProp = Functions.getPhysicalProp
Registry.isPhysicalProp = Functions.isPhysicalProp
Registry.registerDecorativeProp = Functions.registerDecorativeProp
Registry.isDecorativeProp = Functions.isDecorativeProp
Registry.reapplyDecorativeInteractivityBlock = Functions.reapplyDecorativeInteractivityBlock

return Registry
