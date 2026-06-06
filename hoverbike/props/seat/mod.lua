--@include starfall_shenanigans/hoverbike/props/seat/constants.lua
--@include starfall_shenanigans/hoverbike/props/seat/functions.lua

local Seat = {
    Constants = require("starfall_shenanigans/hoverbike/props/seat/constants.lua"),
    Functions = require("starfall_shenanigans/hoverbike/props/seat/functions.lua")
}

Seat.spawn = Seat.Functions.spawn

return Seat
