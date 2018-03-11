local class = require "util/oo"

local TableType = require "luaDeco/decoType/TableType"

local ClassType = class(TableType)

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
