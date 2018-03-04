local class = require "util/oo"
local FunctionType = require "luaDeco/decoType/FunctionType"

local FunctionDeco = class(Decorator)

function FunctionDeco:ctor(vIndex)
	self.mTypeIndex = vIndex
end

local getTypeFromDecoList = function(...)
	local nDecoTuple = table.pack(...)
	local nTuple = {}
	for k,v in ipairs(nDecoTuple) do
		nTuple[#nTuple + 1] = v:getTypeIndex()
	end
	return nTuple
end

local Call=function(...)
	local nFunction = FunctionType.new()
	local nTuple = getTypeFromDecoList(...)
	nFunction:setArgTuple(nArgTuple)
	return {
		Return = function(...)
			local nDecoTuple = table.pack(...)
			local nTuple = getTypeFromDecoList(...)
			nFunction:setRetTuple(nArgTuple)
			return FunctionDeco.new(nFunction:getTypeIndex())
		end
	}
end

return {
	Call = Call
}

