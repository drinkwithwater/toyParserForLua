local class = require "util/oo"
local Decorator = require "luaDeco/decorator/Decorator"
local FunctionType = require "luaDeco/decoType/FunctionType"

local FunctionDeco = class(Decorator)

function FunctionDeco:ctor()
	self.mArgDecoTuple = nil
end

function FunctionDeco:setArgDecoTuple(vArgDecoTuple)
	self.mArgDecoTuple = vArgDecoTuple
end

function FunctionDeco:getArgDecoTuple()
	return self.mArgDecoTuple
end

local getTuple = function(...)
	local nDecoTuple = table.pack(...)
	nDecoTuple.n = nil
	local nTuple = {}
	for k,v in ipairs(nDecoTuple) do
		nTuple[#nTuple + 1] = v:decorator():getTypeIndex()
	end
	return nDecoTuple, nTuple
end

local Call=function(...)
	local nFunction = FunctionType.new()
	local nFuncDeco = FunctionDeco.new()
	nFuncDeco:setTypeIndex(nFunction:getTypeIndex())

	local nDecoTuple, nTuple = getTuple(...)
	nFuncDeco:setArgDecoTuple(nDecoTuple)
	nFunction:setArgTuple(nTuple)


	--[[nFuncDeco.Return=function(...)
		local nDecoTuple, nTuple = getTuple(...)
		nFuncDeco:setRetDecoTuple(nDecoTuple)
		nFunction:setRetTuple(nTuple)

		return nFuncDeco
	end]]

	return nFuncDeco
end


local ColonCall=function(...)
	error("not implement")
end

return {
	Call = Call,
	DotCall = Call,
	ColonCall = ColonCall,
}

