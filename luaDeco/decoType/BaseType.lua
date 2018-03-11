local class = require "util/oo"

local DecoType = require "luaDeco/decoType/DecoType"

local BaseType = class(DecoType)

function BaseType:ctor(vTypeStr)
	self.mTypeStr = vTypeStr
end

function BaseType:contain(vTypeObj)
	if BaseType.checkClass(vTypeObj) then
		return vTypeObj:getTypeStr() == self:getTypeStr()
	else
		return false
	end
end

function BaseType:toString()
	return self.mTypeStr
end

function BaseType:getTypeStr()
	return self.mTypeStr
end

return BaseType
