local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local DecoType = require "luaDeco/decoType/DecoType"
local ClassType = require "luaDeco/decoType/ClassType"

local ClassProtoType = class(DecoType)

function ClassProtoType:ctor()
	self.mDataDict={}
	self.mFunctionDict={}
	self.mClassName = nil
	self.mClassType = ClassType.new()
end

function ClassProtoType:setClassName(vClassName)
	self.mClassName = vClassName
	self.mClassType:setClassName(vClassName)
end

function ClassProtoType:toString()
	return "Class-"..self.mClassName
end

function ClassProtoType:addData(vKey, vData)
	self.mDataDict[vKey] = vData
end

function ClassProtoType:addFunction(vKey, vFunction)
	self.mFunctionDict[vKey] = vFunction
end

function ClassProtoType:createDecorator()
	local Decorator = require "luaDeco/decorator/Decorator"
	local decorator = Decorator.new()
	decorator:setTypeIndex(self.mClassType:getTypeIndex())
	return decorator
end

env.ClassProtoType = ClassProtoType
return ClassProtoType
