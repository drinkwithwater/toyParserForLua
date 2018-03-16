local cjson = require "cjson"
local NodeLogger = require "nodeLogger"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("guess")

	local travelDict={
		stmt={
			["assign"]=function(node)
				rawtravel(node)
				if node.deco_buffer then
					return
				end
				for k,expr in ipairs(node.expr_list) do
				end
			end,
			["local"]=function(node)
				rawtravel(node)
				if node.deco_buffer then
					return
				end
			end,
			["function_stmt"]=function(node)
				rawtravel(node)
				if node.deco_buffer then
					return
				end
			end,
		}
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())
end
