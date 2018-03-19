local class = require "util/oo"
local KeyListDict = require "util/KeyListDict"

local DecoSubDict = class(KeyListDict)

local DECO = 2
local DEDUCE_LIST = 3
local OP_DICT = 4 -- TODO

function DecoSubDict:ctor()
	self[2] = false
	self[3] = false
	self[4] = false
end

return DecoSubDict
