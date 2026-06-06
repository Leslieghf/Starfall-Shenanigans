--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl
--@include starfall_shenanigans/hoverbike/hooks.lua

--[[
Hoverbike executable entry point.

This file should stay boring: Starfall metadata, one include, and hook
installation. Project behavior lives in domain modules:

- hooks.lua bridges raw Starfall hooks to hoverbike schedules.
- schedules/ defines the concrete hook-like execution schedules.
- */systems.lua files register domain systems into those schedules.
- props/, control/, height/, and debug/ contain hoverbike-specific policy.
- ../std/lib.lua documents and exports reusable architecture primitives.
]]

local Hooks = require("starfall_shenanigans/hoverbike/hooks.lua")

Hooks.install()
