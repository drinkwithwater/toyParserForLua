local cjson = require "cjson"
local NodeLogger = require "nodeLogger"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("staticRequireTravel")
	local fileEnv = fileContext:getFileEnv()

	local function getContextFromExpr(expr)
		if expr.__subtype~="prefix_exp" then
			return nil
		elseif expr.prefix_exp.__subtype~="function_call" then
			return nil
		end

		-- check has require
		local fileBody = expr.prefix_exp.__require
		if not fileBody then
			return nil
		else
			return globalContext:getFileContext(fileBody)
		end
	end

	local travelDict={
		stmt={
			["deco_declare"]=function(node)
				-- TODO
				return
			end,
			["assign"]=function(node)
				--[[
				if #node.var_list~=1 or #node.expr_list~=1 then
					rawtravel(node)
					return
				end

				-- check var
				local var=node.var_list[1]
				if var.__subtype~="name" then
					rawtravel(node)
					return
				end

				-- check expr
				local requireFileContext = getContextFromExpr(node.expr_list[1])
				if not requireFileContext then
					rawtravel(node)
					return
				end

				-- TODO parse return
				local retNode = requireFileContext:getLastAstNode()
				if retNode.expr_list then
					local expr = retNode.expr_list
				end]]
			end,
			["local"]=function(node)
			end,
		}
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())
end
