local class = require "luaDeco/oo"

local function nodeInfo(node)
	if type(node)=="table" then
		local a = node.__type .. ((node.__subtype and "."..node.__subtype) or "")
		local b = string.format("(%s)(%s)", node.__row,a)
		return b
	else
		return "not table|"..node
	end
end

local NodeLogger = class()

function NodeLogger:ctor(name)
	local prefix = "["..name.."]"
	self.warning=function(node, ...)
		print("[WARNING]"..prefix..nodeInfo(node), ...)
	end
	self.error=function(node, ...)
		print("[ERROR]"..prefix..nodeInfo(node), ...)
	end
end

return NodeLogger
