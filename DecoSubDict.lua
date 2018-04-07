local class = require "util/oo"
local KeyListDict = require "util/KeyListDict"

local DecoSubDict = class(KeyListDict)

local DECO_TYPE = 2
local NATIVE_TYPE = 3
local DEDUCE_TYPE_LIST = 4
local OP_LIST = 5			-- TODO
local EMPTY = 5

DecoSubDict.DECO_TYPE = DECO_TYPE
DecoSubDict.NATIVE_TYPE = NATIVE_TYPE
DecoSubDict.DEDUCE_TYPE_LIST = DEDUCE_TYPE_LIST
DecoSubDict.EMPTY = EMPTY

function DecoSubDict:ctor()
	self[2] = false
	self[3] = false
	self[4] = false
end

function DecoSubDict:getDecoDeduce()
	if self[DECO_TYPE] then
		return self[DECO_TYPE]
	elseif self[DEDUCE_TYPE_LIST] then
		return self[DEDUCE_TYPE_LIST][1]
	else
		return nil
	end
end


return DecoSubDict
