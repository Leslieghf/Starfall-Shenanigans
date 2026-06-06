--@include functions.lua

local Log = {
    Functions = require("functions.lua")
}

Log.debugPrint = Log.Functions.debugPrint

return Log
