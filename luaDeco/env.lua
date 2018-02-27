local seri = require "seri"
local typeClass = require "luaDeco/typeClass"
local baseClass = require "luaDeco/baseClass"

local deco={}

for k,v in pairs(baseClass) do
	deco[k] = v
end
for k,v in pairs(typeClass) do
	deco[k] = v
end


return deco
