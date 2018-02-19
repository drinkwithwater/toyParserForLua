local log = {}

local function nodeInfo(node)
	if type(node)=="table" then
		local a = node.__type .. ((node.__subtype and "."..node.__subtype) or "")
		local b = string.format("[%d,%d]", node.__row, node.__col)
		return b..a
	else
		return "id|"..node
	end
end

function log.warning(node,...)
	print("[WARNING]",node.__row,nodeInfo(node), ...)
end

function log.error(node,...)
	print("[ERROR]",node.__row,nodeInfo(node), ...)
end

return log
