local class = require "luaDeco/oo"

local function nodeInfo(node)
	if type(node)=="table" then
		local a = node.__type .. ((node.__subtype and "."..node.__subtype) or "")
		local b = string.format("[%d,%d]", node.row, node.col)
		return b..a
	else
		return "id|"..node
	end
end

local NodeLogger = class()

function NodeLogger:ctor(name)
	local prefix = "["..name.."]"
	self.warning=function(node, ...)
		print("[WARNING]"..prefix, node.__row,nodeInfo(node), ...)
	end
	self.error=function(node, ...)
		print("[ERROR]"..prefix, node.__row,nodeInfo(node), ...)
	end
end

return NodeLogger
