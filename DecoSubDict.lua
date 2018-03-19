local class = require "util/oo"
local KeyListDict = require "util/KeyListDict"

local DecoSubDict = class(KeyListDict)

function DecoSubDict:ctor()
	self[2] = false
	self[3] = false
	self[4] = false
end

return DecoSubDict
