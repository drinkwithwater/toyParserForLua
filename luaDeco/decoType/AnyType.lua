require "util/tableExpand"
local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local DecoType = require "luaDeco/decoType/DecoType"

local AnyType = class(DecoType)

function AnyType:ctor()
end

function AnyType:contain(vTypeObj)
	return true
end

function AnyType:toString()
	return "Any"
end

env.AnyType = AnyType
return AnyType
