local class = require "util/oo"

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

function NodeLogger:ctor(name, fileBody)
	local prefix = string.format("[%s.lua][%s]", fileBody, name)
	self.warning=function(node, ...)
		print("[WARNING]"..prefix..nodeInfo(node), ...)
	end
	self.error=function(node, ...)
		print("[ERROR]"..prefix..nodeInfo(node), ...)
	end
	self.result=function(node, ...)
		print("[RESULT]"..prefix..nodeInfo(node), ...)
	end
	self.print=function(...)
		print("[PRINT]"..prefix, ...)
	end
end

return NodeLogger
