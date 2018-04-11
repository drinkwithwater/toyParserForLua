local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local DecoType = require "luaDeco/decoType/DecoType"
local ClassType = require "luaDeco/decoType/ClassType"

local ClassProtoType = class(DecoType)

function ClassProtoType:ctor()
	self.mClassName = nil
	self.mClassType = ClassType.new()
	self.mUpValue = nil
end

function ClassProtoType:setClassName(vClassName)
	self.mClassName = vClassName
	self.mClassType:setClassName(vClassName)
end

-- single upvalue only valid for local_stmt
-- TODO add key list for assign_stmt
function ClassProtoType:setUpValue(vUpValue)
	self.mUpValue = vUpValue
end

function ClassProtoType:toString()
	return "ClassProto("..self.mClassName..")"
end

function ClassProtoType:createDecorator()
	local Decorator = require "luaDeco/decorator/Decorator"
	local decorator = Decorator.new()
	decorator:setTypeIndex(self.mClassType:getTypeIndex())
	return decorator
end

env.ClassProtoType = ClassProtoType
return ClassProtoType
