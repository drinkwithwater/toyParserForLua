local cjson = require "cjson"
local log = require "log"

local travel = nil
local rawtravel = nil
local function setPos(nodeFather, nodeChild)
	nodeFather.col = 0
	nodeFather.row = nodeChild.row
end

local travelDict={
	stmt={
		["deco_declare"]=function(node)
			rawtravel(node)
		end,
		["do"]=function(node)
			rawtravel(node)
			setPos(node, node.block)
		end,
		["for"]=function(node)
			rawtravel(node)
			setPos(node, node.head)
		end,
		["while"]=function(node)
			rawtravel(node)
			setPos(node, node.head)
		end,
		["local"]=function(node)
			rawtravel(node)
			if node.id_list then
				setPos(node, node.id_list)
			elseif node.id then
				setPos(node, node.id)
			end
		end,
		["assign"]=function(node)
			rawtravel(node)
			setPos(node, node.var_list)
		end,
		["function"]=function(node)
			rawtravel(node)
			setPos(node, node.head)
		end,
		["function_call"]=function(node)
			rawtravel(node)
			setPos(node, node.prefix_exp)
		end,
		["if"]=function(node)
			rawtravel(node.head)
			setPos(node, node.expr)
		end,
		["if_else"]=function(node)
			rawtravel(node.head)
			setPos(node, node.expr)
		end,
	},
}

travel = function (node)
	local nType = node.__type
	local nSubType = node.__subtype
	if nType and nSubType and travelDict[nType] and travelDict[nType][nSubType] then
		return travelDict[nType][nSubType](node)
	elseif nType and not nSubType and travelDict[nType] then
		return travelDict[nType](node)
	else
		-- print(nType, nSubType, "not define")
		for k,v in pairs(node) do
			if type(v) == "table" then
				travel(v)
			end
		end
	end
end
rawtravel = function(node)
	for k,v in pairs(node) do
		if type(v) == "table" then
			travel(v)
		end
	end
end

return travel
