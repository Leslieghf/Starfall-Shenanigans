--@include starfall_shenanigans/hoverbike/control/angvel.lua
--@include starfall_shenanigans/hoverbike/control/drive.lua
--@include starfall_shenanigans/hoverbike/control/height.lua
--@include starfall_shenanigans/hoverbike/control/input.lua
--@include starfall_shenanigans/hoverbike/control/manual.lua
--@include starfall_shenanigans/hoverbike/control/rigidbody.lua
--@include starfall_shenanigans/hoverbike/control/vel.lua

local Control = {}

Control.AngVel = require("starfall_shenanigans/hoverbike/control/angvel.lua")
Control.Drive = require("starfall_shenanigans/hoverbike/control/drive.lua")
Control.Height = require("starfall_shenanigans/hoverbike/control/height.lua")
Control.Input = require("starfall_shenanigans/hoverbike/control/input.lua")
Control.Manual = require("starfall_shenanigans/hoverbike/control/manual.lua")
Control.Rigidbody = require("starfall_shenanigans/hoverbike/control/rigidbody.lua")
Control.Vel = require("starfall_shenanigans/hoverbike/control/vel.lua")

return Control
