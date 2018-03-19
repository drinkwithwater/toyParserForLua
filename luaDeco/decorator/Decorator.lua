local class = require "util/oo"

local decoTypeList = require "luaDeco/decoType/decoTypeList"
local MixType = require "luaDeco/decoType/MixType"

local Decorator = class()

function Decorator:setTypeIndex(vTypeIndex)
	self.mTypeIndex = vTypeIndex
	return self
end

function Decorator:getTypeIndex()
	return self.mTypeIndex
end

-- To Be Override
function Decorator:decorator(node, upValue)
	return decoTypeList[self.mTypeIndex]
end

function Decorator:getDecoType()
	return decoTypeList[self.mTypeIndex]
end

function Decorator:addSubNode(vName, vDecorator)
	self[vName] = vDecorator
end

function Decorator:__bor(vRightDeco)
	local nLeftType = decoTypeList[self:getTypeIndex()]
	local nRightType = decoTypeList[vRightDeco:getTypeIndex()]

	if MixType.isClass(nLeftType) then
		nLeftType:add(nRightType)
		return self
	else
		local mixType = MixType.new()
		mixType:add(nLeftType)
		mixType:add(nRightType)
		local newIndex = #decoTypeList + 1
		decoTypeList[newIndex] = mixType
		local deco = Decorator.new()
		deco:setTypeIndex(newIndex)
		return deco
	end

end

return Decorator
