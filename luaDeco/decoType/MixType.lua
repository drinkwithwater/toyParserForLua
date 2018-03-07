require "util/tableExpand"
local class = require "util/oo"
local DecoType = require "luaDeco/decoType/DecoType"
local decoTypeList = require "luaDeco/decoType/decoTypeList"

local MixType = class(DecoType)

function MixType:ctor()
	self.mBorList = {}
end

function MixType:add(vItem)
	if MixType.isClass(vItem) then
		local nList = vItem:getBorList()
		for k,v in pairs(nList) do
			self.mBorList[#self.mBorList + 1] = v:getTypeIndex()
		end
	else
		self.mBorList[#self.mBorList + 1] = vItem:getTypeIndex()
	end
end

function MixType:getBorList()
	return self.mBorList
end

function MixType:toString()
	local nList = table.map(self.mBorList, function(v, k)
		return decoTypeList[v]:toString()
	end)
	return table.concat(nList, "|")
end

return MixType
