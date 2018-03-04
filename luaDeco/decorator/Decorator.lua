local class = require "util/oo"

local decoTypeList = require "luaDeco/decoType/decoTypeList"

local Decorator = class()

function Decorator:getTypeIndex()
	return self.mTypeIndex
end

function Decorator:decorator(node)
	return decoTypeList[self.mTypeIndex]
end

function Decorator:addSubNode(vName, vDecorator)
	self[vName] = vDecorator
end

function Decorator:__bor(vLeftDeco, vRightDeco)
	local nLeftType = decoTypeList[vLeftDeco:getTypeIndex()]
	local nRightType = decoTypeList[vRightDeco:getTypeIndex()]

	local mixType = MixType.new()
	mixType:add(nLeftType)
	mixType:add(nRightType)

	local newIndex = #decoTypeList + 1
	decoTypeList[newIndex] = mixType
	return Decorator.new(newIndex)
end

return Decorator
