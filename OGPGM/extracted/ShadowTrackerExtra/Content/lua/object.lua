local class = require "class"

local obj = {}
setmetatable(obj, {__call = function () return {} end})

return class(obj, nil, nil)