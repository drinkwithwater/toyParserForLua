local class = require "util/oo"
local Decorator = require "luaDeco/decorator/Decorator"
local FunctionType = require "luaDeco/decoType/FunctionType"

local decoTypeEnv = require "luaDeco/decoType/env"

local cjson = require "cjson"
decoTypeEnv.Function = FunctionType.new()

local FunctionDeco = class(Decorator)

function FunctionDeco:ctor()
end

function FunctionDeco:getArgDecoTuple()
	local argTuple = self:getDecoType():getArgTuple() or {}
	return table.map(argTuple, function(v, k)
		local deco = Decorator.new()
		deco:setTypeIndex(v:getTypeIndex())
		return deco
	end)
end

local getTypeTuple = function(...)
	local nDecoTuple = table.pack(...)
	nDecoTuple.n = nil
	local nTypeTuple = table.map(nDecoTuple, function(v, k)
		return v:getDecoType()
	end)
	return nTypeTuple
end

local function Call(...)
	local nFunction = FunctionType.new()
	local nFuncDeco = FunctionDeco.new()

	nFuncDeco:setTypeIndex(nFunction:getTypeIndex())

	local nTypeTuple = getTypeTuple(...)
	if nTypeTuple[#nTypeTuple] == decoTypeEnv.Dot3 then
		nTypeTuple[#nTypeTuple] = nil
		nFunction:setArgTuple(nTypeTuple)
		nFunction:setArgDot3(true)
	else
		nFunction:setArgTuple(nTypeTuple)
		nFunction:setArgDot3(false)
	end

	nFuncDeco.Return=function(...)
		local nTypeTuple = getTypeTuple(...)
		if nTypeTuple[#nTypeTuple] == decoTypeEnv.Dot3 then
			nTypeTuple[#nTypeTuple] = nil
			nFunction:setRetTuple(nTypeTuple)
			nFunction:setRetDot3(true)
		else
			nFunction:setRetTuple(nTypeTuple)
			nFunction:setRetDot3(false)
		end

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

