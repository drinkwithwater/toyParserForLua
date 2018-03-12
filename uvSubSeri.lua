local DecoType = require "luaDeco/decoType/DecoType"
local KeyListDict = require "util/keyListDict"

local function serialize(obj, depth)
	depth = depth or 0
	local indent, subIndent, newLine
	if depth < 0 then
		depth = -2
		indent = ""
		subIndent = ""
		newLine = ""
	else
		indent = string.rep("  ", depth)
		subIndent = string.rep("  ", depth+1)
		newLine = "\n"
	end

	local lua = ""
	local t = type(obj)
	if t == "number" then
		lua = lua .. obj
	elseif t == "boolean" then
		lua = lua .. tostring(obj)
	elseif t == "string" then
		lua = lua .. string.format("%q", obj)
	elseif t == "table" then
		if DecoType.isClass(obj) then
			lua = lua .. "Type["..obj:toString().."]"
		elseif KeyListDict.checkClass(obj) then
			local first = nil
			if obj[1] then
				first = serialize(obj[1], -1)
			else
				first = "Type[unknown]"
			end
			lua = lua ..first.." "..serialize(obj[2], depth)
		else
			lua = lua .. "{"..newLine
			for k, v in pairs(obj) do
				local leftEqa = nil
				if type(k) == "string" then
					leftEqa = k.."="
				else
					leftEqa = "["..serialize(k, -1).."]="
				end
				lua = lua ..subIndent.. leftEqa .. serialize(v, depth+1) .. ","..newLine
			end
			lua = lua..indent.."}"
		end
	elseif t == "nil" then
		return nil
	else
		-- do nothing for function
	end
	return lua
end

return serialize