--@name Hoverbike
--@server
--@model models/hunter/plates/plate1x2.mdl

local DRAG = 1.5
local counter = 0
local log_delay = 60

hook.add("think", "drag", function()

    local ent = chip()

    local vel = ent:getVelocity()

    local mass = ent:getMass()
    
    local baseGravity = 9.01352
    local gravity = baseGravity
    
    if (counter % log_delay) == 0 then
        print("[Hoverbike] Current Velocity: ", vel)
    end

    local force =
    Vector(0,0,mass*gravity)
    - vel * DRAG * mass

    ent:applyForceCenter(force)
    counter = counter + 1
end)