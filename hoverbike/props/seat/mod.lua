--@include constants.lua
--@include functions.lua

local Seat = {
    Constants = require("constants.lua"),
    Functions = require("functions.lua")
}

Seat.spawn = Seat.Functions.spawn

return Seat
