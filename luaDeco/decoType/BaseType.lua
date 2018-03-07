local class = require "util/oo"
local DecoType = require "luaDeco/decoType/DecoType"

local BaseType = class(DecoType)

function BaseType:ctor(vTypeStr)
	self.mTypeStr = vTypeStr
end

function BaseType:toString()
	return self.mTypeStr
end

return BaseType
