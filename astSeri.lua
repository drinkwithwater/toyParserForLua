
local key={
	__subtype=true,
	__type=true,
	__row=true,
	__col=true,
}
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
		local typeStr = "("..(obj.__type or "")..","..(obj.__subtype or "")..""
		lua = lua .." "..typeStr.." {"..newLine
		for k, v in pairs(obj) do
			if not key[k] then
				local keyEq = "[".. serialize(k, -1) .. "]="
				if type(k) == "string" then
					keyEq = k .."="
				end
				lua = lua ..subIndent.. keyEq .. serialize(v, depth+1) .. ","..newLine
			end
		end
		--[[local metatable = getmetatable(obj)
		if metatable ~= nil and type(metatable.__index) == "table" then
			for k, v in pairs(metatable.__index) do
				lua = lua .. subIndent.."[" .. serialize(k, -1) .. "]=" .. serialize(v, depth+1) .. ","..newLine
			end
		end]]
		lua = lua..indent.."}"
	elseif t == "nil" then
		return nil
	else
		-- do nothing for function
	end
	return lua
end

return serialize
