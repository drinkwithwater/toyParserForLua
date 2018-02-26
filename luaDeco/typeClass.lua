local class = require "util/oo"

local DecoType = nil
local SimpleType = nil
local FunctionType, ClassType = nil, nil
local MixType = nil

DecoType = class()

function DecoType:__bor(vLeft, vRight)
	local newType = MixType.new()
	MixType:add(vLeft)
	MixType:add(vRight)
end

function DecoType:decorator(node)
	return self
end

SimpleType = class(DecoType)

function SimpleType:ctor(vTypeStr)
	self.mTypeStr = vTypeStr
end

MixType = class(DecoType)
function MixType:ctor()
	self.mBorList = {}
end

function MixType:add(vItem)
	if MixType.isClass(vItem) then
		local nList = vItem:getBorList()
		for k,v in pairs(nList) do
			self.mBorList[#self.mBorList + 1] = v
		end
	else
		self.mBorList[#self.mBorList + 1] = vItem
	end
end

function MixType:getBorList()
	return self.mBorList
end

FunctionType = class(DecoType)
function FunctionType:ctor()
	self.mArgTuple={}
	self.mRetTuple={}
end

function FunctionType:setArgTuple(...)
	self.mArgTuple = table.pack(...)
	self.mArgTuple.n = nil
end

function FunctionType:setRetTuple(...)
	self.mRetTuple = table.pack(...)
	self.mRetTuple.n = nil
end

function FunctionType:getArgTuple()
	return self.mArgTuple
end

function FunctionType:getRetTuple()
	return self.mRetTuple
end

local function typeAssetWarning(leftType, rightType, info)
	-- TODO use |
	if leftType ~= rightType then
		local str=string.format("[WARNING] left=%s right=%s %s", leftType,rightType,info)
		print(str)
	end
end

return {
	DecoType = DecoType,
	SimpleType = SimpleType,
	FunctionType = FunctionType,
	ClassType = ClassType,
	MixType = MixType,
	typeAssetWarning = typeAssetWarning
}
