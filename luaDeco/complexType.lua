local class = require "util/oo"

local typeClass = require "typeClass"

local ClassType = class(typeClass.DecoType)

function ClassType:ctor()
	self.mSubDict = {}
end

function ClassType:setSubType(vKey, vDecoType)
	self.mSubDict[vKey] = vDecoType
end

function ClassType:getSubType(vKey)
	return self.mSubDict[vKey]
end

function ClassType:getSubDict()
	return self.mSubDict
end

local function Class()
	return ClassType.new()
end

return {
	Class = Class
}
