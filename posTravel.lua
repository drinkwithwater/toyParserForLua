local cjson = require "cjson"
local log = require "log"

return function(ast)
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
				if node.name_list then
					setPos(node, node.name_list)
				elseif node.name then
					setPos(node, node.name)
				end
			end,
			["assign"]=function(node)
				rawtravel(node)
				setPos(node, node.var_list)
			end,
			["function"]=function(node)
				rawtravel(node)
				setPos(node, node.var_function)
			end,
			["function_call"]=function(node)
				rawtravel(node)
				setPos(node, node.prefix_exp)
			end,
			["if"]=function(node)
				rawtravel(node)
				setPos(node, node.expr)
			end,
		},
	}

	local travelFactory = require "travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)

	travel(ast)
end
