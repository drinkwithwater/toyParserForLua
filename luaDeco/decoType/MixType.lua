require "util/tableExpand"
local class = require "util/oo"
local env = require "luaDeco/decoType/env"

local DecoType = require "luaDeco/decoType/DecoType"

local MixType = class(DecoType)

function MixType:ctor()
	self.mBorList = {}
end

function MixType:add(vItem)
	if MixType.checkClass(vItem) then
		local nList = vItem:getBorList()
		for k,v in pairs(nList) do
			self.mBorList[#self.mBorList + 1] = v
		end
	else
		self.mBorList[#self.mBorList + 1] = vItem
	end
end

function MixType:contain(vTypeObj)
	if MixType.checkClass(vTypeObj) then
		error("TODO...MixType contain MixType...")
	end
	for k, nTypeObj in pairs(self.mBorList) do
		if nTypeObj:contain(vTypeObj) then
			return true
		end
	end
	return false
end

function MixType:getBorList()
	return self.mBorList
end

function MixType:toString()
	local nList = table.map(self.mBorList, function(v, k)
		return v:toString()
	end)
	return table.concat(nList, "|")
end

env.MixType = MixType
return MixType
