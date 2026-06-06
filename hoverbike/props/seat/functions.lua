--@include starfall_shenanigans/hoverbike/props/functions.lua
--@include starfall_shenanigans/hoverbike/props/seat/constants.lua

local PropFunctions = require("starfall_shenanigans/hoverbike/props/functions.lua")
local SeatConstants = require("starfall_shenanigans/hoverbike/props/seat/constants.lua")

local SeatFunctions = {}

function SeatFunctions.spawn(chipEnt)
    PropFunctions.spawnSeat(
        chipEnt:getPos() + SeatConstants.OFFSET,
        chipEnt:getAngles(),
        SeatConstants.MODEL,
        SeatConstants.FROZEN,
        SeatConstants.NAME,
        function(seat)
            constraint.weld(seat, chipEnt)
        end
    )
end

return SeatFunctions
