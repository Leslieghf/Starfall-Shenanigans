--@include ../functions.lua
--@include constants.lua

local PropFunctions = require("../functions.lua")
local SeatConstants = require("constants.lua")

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
