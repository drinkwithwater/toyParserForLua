require  "util/tableExpand"
local class = require "util/oo"
local KeyListDict = require "util/KeyListDict"
local uvSubSeri = require "uvSubSeri"

local TreeType = class(KeyListDict)

function TreeType:ctor()
	self[1] = {}
	self[2] = false
end

function TreeType:add(vConstList, vType)
	self:setKeyListValue(vConstList, vType, 2)
end

function TreeType:toString(depth)
	return uvSubSeri(self, depth)
end

return TreeType
