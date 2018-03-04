local class = require "util/oo"
local DecoType = require "luaDeco/decoType/DecoType"

local BaseType = class(DecoType)

function BaseType:ctor(vTypeStr)
	self.mTypeStr = vTypeStr
end

local dict = {
	String=String,
	Number=Number,
	Table=Table,
	Boolean=Boolean,
	Nil=Nil,
	Call=Call,
	Dot3=Dot3,
	Class=Class,
}

return BaseType
