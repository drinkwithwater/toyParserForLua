local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local AstNode = require "astNode"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("classDefine", fileContext:getFileBody())

	local uvTree = fileContext:getUVTree()

	local function checkExprClass(expr)
		local funcCall = AstNode.checkExprCall(expr)
		if not funcClass then
			return false
		end
		local args = AstNode.checkCall(funcCall, "class")
		if not args then
			return false
		else
			return true
		end
	end

	local travelDict={
		stmt={
			["local"]=function(node)
				if not node.expr_list then
					return
				end
				if #node.expr_list ~= 1 then
					return
				end

				local name = node.name_list[1].name

				if not checkExprClass(node.expr_list[1]) then
					return
				else
					print("define class:",name)
				end
			end,
			["assign"]=function(node)
			end
		},

	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())

end
