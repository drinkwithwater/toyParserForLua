local cjson = require "cjson"

local function checkKeyValue(key, value)
	if type(value) ~= "table" then
		return false
	end
	if type(key) == "string" then
		if key:sub(1,2) == "__" then
			return false
		end
	end
	return true
end
local function create(travelDict)
	local rawtravel = nil
	local travel = nil
	rawtravel = function(node)
		for k,v in pairs(node) do
			if checkKeyValue(k,v) then
				travel(v)
			end
		end
	end
	travel = function(node)
		local nType = node.__type
		local nSubType = node.__subtype
		if nType and nSubType then
			if type(travelDict[nType])=="table" and travelDict[nType][nSubType] then
				return travelDict[nType][nSubType](node)
			elseif type(travelDict[nType])=="function" then
				return travelDict[nType](node)
			end
		elseif nType and not nSubType then
			if type(travelDict[nType])=="function" then
				return travelDict[nType](node)
			end
		end
		return rawtravel(node)
	end
	return travel, rawtravel
end

local TravelFactory={
	create = create
}

return TravelFactory
