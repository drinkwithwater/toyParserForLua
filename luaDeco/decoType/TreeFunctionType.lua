require  "util/tableExpand"
local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local DecoType = require "luaDeco/decoType/DecoType"

local TreeFunctionType = class(DecoType)

function TreeFunctionType:ctor()
	self[1] = false
	self[2] = {}
end

function TreeFunctionType:add(vConstList, vFunctionType)
	if not vConstList then
		self[1] = vFunctionType
	else
		local pointer = self
		for _, aKey in ipairs(vConstList) do
			local nextPointer = pointer[2][aKey]
			if not nextPointer then
				nextPointer = {false, {}}
				pointer[2][aKey] = nextPointer
			end
			pointer = nextPointer
		end
		pointer[1] = vFunctionType
	end
end

local function nodeToString(vStack, vType)
	local nStrList = {}
	for k,v in pairs(vStack) do
		if type(v) == "table" then
			nStrList[#nStrList + 1] = v:toString()
		elseif type(v) == "string" then
			nStrList[#nStrList + 1] = "\""..v.."\""
		elseif type(v) == "number" then
			nStrList[#nStrList + 1] = tostring(v)
		end
	end
	nStrList[#nStrList + 1] = vType:toString()
	return table.concat(nStrList, ",")
end

function TreeFunctionType:toString(vStack)
	local nStack = vStack or {}
	local nStrList = {}

	if self then
		local nType = self[1]
		if nType then
			nStrList[#nStrList + 1] = nodeToString(nStack, nType)
		end
		local nLastIndex = #nStack + 1
		for key, nextSelf in pairs(self[2]) do
			nStack[nLastIndex] = key
			local nRetStrList = TreeFunctionType.toString(nextSelf, nStack)
			for _k, str in pairs(nRetStrList) do
				nStrList[#nStrList + 1] = str
			end
		end
		nStack[nLastIndex] = nil
	end
	if not vStack then
		return table.concat(nStrList, "|")
	else
		return nStrList
	end
end

env.TreeFunctionType = TreeFunctionType
return TreeFunctionType
