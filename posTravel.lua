local cjson = require "cjson"
local log = require "log"


local travel = nil
local rawtravel = nil
local function setPos(nodeFather, nodeChild)
	nodeFather.__col = 0
	nodeFather.__row = nodeChild.__row
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

local travelFactory = require "travelFactory"
travel, rawtravel = travelFactory.create(travelDict)

return travel
