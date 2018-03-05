local class = require "util/oo"
local DecoType = require "luaDeco/decoType/DecoType"

local SkynetType = class(DecoType)

function SkynetType:ctor()
	self.mFunctionDict={}
end

function SkynetType:addFunction(vKey, vFunction)
	self.mFunctionDict[vKey] = vFunction
end

return SkynetType
