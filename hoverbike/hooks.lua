--@include schedules/mod.lua

local Schedules = require("schedules/mod.lua")

local Hooks = {}

function Hooks.install()
    Schedules.installSystems()

    hook.add("Think", "HoverbikeUpdate", Schedules.runThink)
    hook.add("EntityRemoved", "HoverbikeCleaning", Schedules.runEntityRemoved)
    hook.add("PlayerDisconnected", "HoverbikePhysgunDisconnect", Schedules.runPlayerDisconnected)
    hook.add("OnPlayerPhysicsPickup", "HoverbikeDecorativePhysicsPickup", Schedules.runPlayerPhysicsPickup)
    hook.add("OnPhysgunPickup", "HoverbikePhysgunPickup", Schedules.runPhysgunPickup)
    hook.add("PhysgunDrop", "HoverbikePhysgunDrop", Schedules.runPhysgunDrop)
end

return Hooks
