local class = require "util/oo"

--@Class
local KeyListDict = class()
function KeyListDict:ctor()
	self[1] = {}
end

--@Call(Table, Any, Number)
function KeyListDict:setKeyListValue(keyList, value, i)
	local index = i or 2
	local pointer = self
	if keyList then
		for _, aKey in ipairs(keyList) do
			local nextPointer = pointer[1][aKey]
			if not nextPointer then
				nextPointer = getmetatable(self).new()
				pointer[1][aKey] = nextPointer
			end
			pointer = nextPointer
		end
	end
	pointer[index] = value
end

--@Call(Table, Number)
function KeyListDict:getKeyListValue(keyList, i)
	local index = i or 2
	if not keyList then
		return self[index]
	else
		local pointer = self
		for _, aKey in ipairs(keyList) do
			local nextPointer = pointer[1][aKey]
			if not nextPointer then
				return nil
			end
			pointer = nextPointer
		end
		return pointer[index]
	end
end

return KeyListDict
