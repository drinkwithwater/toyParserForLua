local class = require "util/oo"

--@Class
local KeyListDict = class()
function KeyListDict:ctor()
	self[1] = false
	self[2] = {}
end

--@Call(Table, Table)
function KeyListDict:setKeyListValue(keyList, value)
	if not keyList then
		self[1] = value
	else
		local pointer = self
		for _, aKey in ipairs(keyList) do
			local nextPointer = pointer[2][aKey]
			if not nextPointer then
				nextPointer = KeyListDict.bindFunction({false, {}})
				pointer[2][aKey] = nextPointer
			end
			pointer = nextPointer
		end
		pointer[1] = value
	end
end

--@Call(Table)
function KeyListDict:getKeyListValue(keyList)
	if not keyList then
		return self[1]
	else
		local pointer = self
		for _, aKey in ipairs(keyList) do
			local nextPointer = pointer[2][aKey]
			if not nextPointer then
				return nil
			end
			pointer = nextPointer
		end
		return pointer[1]
	end
end

return KeyListDict
