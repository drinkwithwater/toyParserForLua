local class = require "util/oo"
local DecoType = require "luaDeco/decoType/DecoType"

local MixType = class(DecoType)

function MixType:ctor()
	self.mBorList = {}
end

function MixType:add(vItem)
	if MixType.isClass(vItem) then
		local nList = vItem:getBorList()
		for k,v in pairs(nList) do
			self.mBorList[#self.mBorList + 1] = v
		end
	else
		self.mBorList[#self.mBorList + 1] = vItem
	end
end

function MixType:getBorList()
	return self.mBorList
end

return MixType
