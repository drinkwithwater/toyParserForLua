local class = require "util/oo"
local DecoType = require "luaDeco/decoType/DecoType"

local ClassType = class(DecoType)

function ClassType:ctor()
	self.mDataDict={}
	self.mFunctionDict={}
end

function ClassType:addData(vKey, vData)
	self.mDataDict[vKey] = vData
end

function ClassType:addFunction(vKey, vFunction)
	self.mFunctionDict[vKey] = vFunction
end

return ClassType
