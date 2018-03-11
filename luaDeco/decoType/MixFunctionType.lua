require  "util/tableExpand"
local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local decoTypeList = require "luaDeco/decoType/decoTypeList"

local DecoType = require "luaDeco/decoType/DecoType"

local MixFunctionType = class(DecoType)

function MixFunctionType:ctor()
	self[1] = nil
	self[2] = {}
end

function MixFunctionType:add(vConstList, vFunctionType)
	if not vConstList then
		self[1] = vFunctionType:getTypeIndex()
	else
		local pointer = self
		for _, aKey in ipairs(vConstList) do
			local nextPointer = pointer[2][aKey]
			if not nextPointer then
				nextPointer = {nil, {}}
				pointer[2][aKey] = nextPointer
			end
			pointer = nextPointer
		end
		pointer[1] = vFunctionType:getTypeIndex()
	end
end

function MixFunctionType:toString()
	error("TODO")
end

env.MixFunctionType = MixFunctionType
return MixFunctionType
