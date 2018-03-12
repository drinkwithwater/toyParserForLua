require  "util/tableExpand"
local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local decoTypeList = require "luaDeco/decoType/decoTypeList"

local DecoType = require "luaDeco/decoType/DecoType"

local FunctionType = class(DecoType)

function FunctionType:ctor()
	self.mArgTuple=nil
	self.mRetTuple=nil
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

function FunctionType:toString()
	local buf = ""
	if self.mArgTuple then
		local nList = table.map(self.mArgTuple, function(v, k)
			return v:toString()
		end)
		buf = buf..string.format("Call(%s)", table.concat(nList, ","))
	else
		buf = "Call()"
	end
	return buf
end

env.FunctionType = FunctionType
return FunctionType
