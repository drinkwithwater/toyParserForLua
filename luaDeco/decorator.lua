local class = require "util/oo"

local decoClassList = {}

local Decorator = class()

function Decorator:ctor(vClassIndex)
	self.mClassIndex = vClassIndex
end

function Decorator:getClassIndex()
	return self.mClassIndex
end

function Decorator:decorator(node)
	return decoClassList[self.mClassIndex]
end

function Decorator:addSubNode(vName, vDecorator)
	self[vName] = vDecorator
end

function Decorator:__bor(vLeftDeco, vRightDeco)
	local nLeftClass = decoClassList[vLeftDeco:getClassIndex()]
	local nRightClass = decoClassList[vRightDeco:getClassIndex()]

	local mixType = MixType.new()
	mixType:add(nLeftClass)
	mixType:add(nRightClass)

	local newIndex = #decoClassList + 1
	decoClassList[newIndex] = mixType
	return Decorator.new(newIndex)
end
