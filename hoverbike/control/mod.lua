--@include angvel.lua
--@include drive.lua
--@include height.lua
--@include input.lua
--@include manual.lua
--@include rigidbody.lua
--@include vel.lua

local Control = {}

Control.AngVel = require("angvel.lua")
Control.Drive = require("drive.lua")
Control.Height = require("height.lua")
Control.Input = require("input.lua")
Control.Manual = require("manual.lua")
Control.Rigidbody = require("rigidbody.lua")
Control.Vel = require("vel.lua")

return Control
