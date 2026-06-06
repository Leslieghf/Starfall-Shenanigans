--@include starfall_shenanigans/std/cache/mod.lua
--@include starfall_shenanigans/std/math/mod.lua
--@include starfall_shenanigans/std/pipeline/mod.lua
--@include starfall_shenanigans/std/schedules/mod.lua

--[[
Std reusable library root.

This project is the non-executable side of the repo. It should not contain chip
entry points, hooks, game-specific schedules, or hoverbike policy. It exports
small reusable building blocks and documents the module structure used by the
actual chip projects.

Starfall module convention:

- Use full Starfall data-root include/require paths without a leading slash.
  Example shape: starfall_shenanigans/hoverbike/... or starfall_shenanigans/std/...
- Reusable std modules are a sibling of hoverbike in the deployment root, so
  hoverbike reaches them through starfall_shenanigans/std/...
- Do not use bare runtime keys such as a plain functions.lua import. They can
  be interpreted from the entrypoint context instead of the current module
  directory.

Project layout semantics:

- main.lua belongs to executable projects only. It is the Starfall chip entry.
- lib.lua belongs to reusable projects only. It is a library facade.
- mod.lua is a domain or subdomain entry point.
- hooks.lua is project-specific glue from raw Starfall/GMod hooks to project
  schedules. It does not belong in std.
- schedules/ in executable projects is project-specific orchestration, usually
  one tight mod.lua per hook-like schedule. std/schedules only provides the
  reusable schedule primitives.
- systems.lua is distributed by domain. A domain registers its own systems into
  schedules instead of sending everything through one global systems file.
- classes.lua is for constructor-bearing class-like modules. Constructor names
  should be explicit, such as newCache(...) or newPipeline(...).
- functions.lua is for stateless operations.
- constants.lua, types.lua, variables.lua, resources.lua, tables.lua, etc. are
  optional. Add them only when the name explains real domain structure.

Exported domains:

- Cache: cached value class, newCache(...).
- Pipeline: queued work class, newPipeline(...).
- Math: scalar/vector helper functions.
- Schedules: newSchedule(...), registerSystem(...), and runSystems(...). Concrete
  schedules own their own run behavior in the consuming project.
]]

local Std = {}

Std.Cache = require("starfall_shenanigans/std/cache/mod.lua")
Std.Math = require("starfall_shenanigans/std/math/mod.lua")
Std.Pipeline = require("starfall_shenanigans/std/pipeline/mod.lua")
Std.Schedules = require("starfall_shenanigans/std/schedules/mod.lua")

return Std
