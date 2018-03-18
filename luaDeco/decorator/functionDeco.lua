local class = require "util/oo"
local Decorator = require "luaDeco/decorator/Decorator"
local FunctionType = require "luaDeco/decoType/FunctionType"

local decoTypeEnv = require "luaDeco/decoType/env"

decoTypeEnv.Function = FunctionType.new()

local FunctionDeco = class(Decorator)

function FunctionDeco:ctor()
	self.mArgDecoTuple = nil
	self.mRetDecoTuple = nil
end

function FunctionDeco:setArgDecoTuple(vArgDecoTuple)
	self.mArgDecoTuple = vArgDecoTuple
end

function FunctionDeco:getArgDecoTuple()
	return self.mArgDecoTuple
end

function FunctionDeco:setRetDecoTuple(vDecoTuple)
	self.mRetDecoTuple = vDecoTuple
end

function FunctionDeco:getRetDecoTuple()
	return self.mRetDecoTuple
end

local getTuple = function(...)
	local nDecoTuple = table.pack(...)
	nDecoTuple.n = nil
	local nTypeTuple = {}
	for k,v in ipairs(nDecoTuple) do
		nTypeTuple[#nTypeTuple + 1] = v:decorator()
	end
	return nDecoTuple, nTypeTuple
end

local function Call(...)
	local nFunction = FunctionType.new()
	local nFuncDeco = FunctionDeco.new()
	nFuncDeco:setTypeIndex(nFunction:getTypeIndex())

	local nDecoTuple, nTypeTuple = getTuple(...)
	nFuncDeco:setArgDecoTuple(nDecoTuple)
	nFunction:setArgTuple(nTypeTuple)

	nFuncDeco.Return=function(...)
		local nDecoTuple, nTypeTuple = getTuple(...)
		nFuncDeco:setRetDecoTuple(nDecoTuple)
		nFunction:setRetTuple(nTypeTuple)

		return nFuncDeco
	end

	return nFuncDeco
end

local Function = FunctionDeco.new()

Function:setTypeIndex(decoTypeEnv.Function:getTypeIndex())

return {
	Function = Function,
	Call = Call

}

