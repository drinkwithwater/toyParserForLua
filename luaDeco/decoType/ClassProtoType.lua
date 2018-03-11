local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local DecoType = require "luaDeco/decoType/DecoType"
local ClassType = require "luaDeco/decoType/ClassType"

local ClassProtoType = class(DecoType)

function ClassProtoType:ctor()
	self.mClassType = ClassType.new()
	self.mDataDict={}
	self.mFunctionDict={}
end

function ClassProtoType:addData(vKey, vData)
	self.mDataDict[vKey] = vData
end

function ClassProtoType:addFunction(vKey, vFunction)
	self.mFunctionDict[vKey] = vFunction
end

function ClassProtoType:createDecorator()
	local classDeco = require "luaDeco/decorator/classDeco"
	return classDeco.ClassDeco.new(self.mClassType:getTypeIndex())
end

env.Class = ClassProtoType
return ClassProtoType
