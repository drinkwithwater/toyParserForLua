local class = require "util/oo"
local Decorator = require "luaDeco/decorator/Decorator"

local ClassProtoType = require "luaDeco/decoType/ClassProtoType"

local ClassProtoDeco = class(Decorator)

function ClassProtoDeco:decorator(node, upValue, fileContext, globalContext)
	local classProtoType = ClassProtoType.new()
	local className = fileContext:getFileBody().."#"..node.name
	classProtoType:setClassName(className)
	return classProtoType
end

local Class = ClassProtoDeco.new()

return {
	Class=Class,
}
