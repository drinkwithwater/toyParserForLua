local class = require "util/oo"
local DecoTypeList = require "luaDeco/decoType/decoTypeList"

local DecoType = class()

function DecoType:ctor()
	local newIndex = #DecoTypeList + 1
	DecoTypeList[newIndex] = self
	self.mTypeIndex = newIndex
end

function DecoType:getTypeIndex()
	return self.mTypeIndex
end

local function typeAssetWarning(leftType, rightType, info)
	-- TODO use |
	if leftType ~= rightType then
		local str=string.format("[WARNING] left=%s right=%s %s", leftType,rightType,info)
		print(str)
	end
end

return DecoType
