local class = require "util/oo"
local TreeFunctionType = require "luaDeco/decoType/TreeFunctionType"
local FunctionType = require "luaDeco/decoType/FunctionType"

local SkynetEmbed = class()

function SkynetEmbed:ctor()
	self.mTree = TreeFunctionType.new()
end

function SkynetEmbed:__call(...)
	local list = table.pack(...)
	local lastIndex = #list
	local upValue = list[lastIndex]
	list[lastIndex] = nil
	local subNodeDict = upValue:getTypeListDict()[1]

	for lastKey, subNode in pairs(subNodeDict) do
		list[lastIndex] = lastKey
		local funcType = subNode[2] or (subNode[3] and subNode[3][1])
		if FunctionType.isClass(funcType) then
			self.mTree:add(list, funcType)
		else
			print("error not a function !!!")
		end
	end
end

function SkynetEmbed:toString()
	return "\n"..table.concat(self.mTree:toString({}), "\n")
end

return {
	SkynetEmbed = SkynetEmbed
}
