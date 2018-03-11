require "util/tableExpand"
local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local decoTypeList = require "luaDeco/decoType/decoTypeList"

local DecoType = class()

function DecoType:ctor()
	local newIndex = #decoTypeList + 1
	decoTypeList[newIndex] = self
	self.mTypeIndex = newIndex
end

function DecoType:__bor(vObj)
	if vObj == env.Any or self == env.Any then
		return env.Any
	else
		local reType = env.MixType.new()
		reType:add(self)
		reType:add(vObj)
		return reType
	end
end

function DecoType:__le(vTypeObj)
	return vTypeObj:contain(self)
end

function DecoType:contain(vObj)
	if self == vObj then
		return true
	else
		return false
	end
end

function DecoType:getTypeIndex()
	return self.mTypeIndex
end

function DecoType:toString()
	return "not_implement"
end

local function typeAssetWarning(leftType, rightType, info)
	-- TODO use |
	if leftType ~= rightType then
		local str=string.format("[WARNING] left=%s right=%s %s", leftType,rightType,info)
		print(str)
	end
end

env.DecoType = DecoType
return DecoType
