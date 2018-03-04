local class = require "util/oo"
local Decorator = require "luaDeco/decorator/Decorator"

local ClassProtoType = require "luaDeco/decoType/ClassProtoType"
local ClassType = require "luaDeco/decoType/ClassType"

local ClassDeco = class(Decorator)

function ClassDeco:ctor(vIndex)
	self.mTypeIndex = vIndex
end

local ClassProtoDeco = class(Decorator)

function ClassProtoDeco:decorator(node)
	return ClassProtoType.new()
end

local Class = ClassProtoDeco.new()

return {
	Class=Class,
	ClassDeco = ClassDeco
}
