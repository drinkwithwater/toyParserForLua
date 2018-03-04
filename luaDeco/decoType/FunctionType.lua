local class = require "util/oo"
local DecoType = require "luaDeco/decoType/DecoType"

local FunctionType = class(DecoType)

function FunctionType:ctor()
	self.mArgTuple={}
	self.mRetTuple={}
end

function FunctionType:setArgTuple(vList)
	self.mArgTuple = vList
end

function FunctionType:setRetTuple(vList)
	self.mRetTuple = vList
end

function FunctionType:getArgTuple()
	return self.mArgTuple
end

function FunctionType:getRetTuple()
	return self.mRetTuple
end


return FunctionType
