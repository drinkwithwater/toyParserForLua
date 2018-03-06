local dict = {}

local simpleDeco = require "luaDeco/decorator/simpleDeco"
for k,v in pairs(simpleDeco) do
	dict[k] = v
end

local classDeco = require "luaDeco/decorator/classDeco"
dict.Class = classDeco.Class

local functionDeco = require "luaDeco/decorator/functionDeco"
for k,v in pairs(functionDeco) do
	dict[k] = v
end

return dict
