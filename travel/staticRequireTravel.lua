local cjson = require "cjson"
local NodeLogger = require "nodeLogger"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("staticRequire", fileContext:getFileBody())

	local travelDict={
		stmt={
			["function"]=function(node)
				-- do nothing
				return
			end,
			["local"]=function(node)
				if node.block then
					-- do nothing
					return
				else
					rawtravel(node)
				end
			end,
			["function_lambda"]=function(node)
				-- do nothing
				return
			end,
			["function_call"]=function(node)
				if node.name then
					-- can't be a:b
					rawtravel(node)
					return
				end
				-- check prefix_exp = require
				local funcVar = node.prefix_exp
				if funcVar.__type~="var" or funcVar.__subtype~="name" then
					rawtravel(node)
					return
				end
				local nameNode = funcVar.name
				if nameNode.name~="require" then
					rawtravel(node)
					return
				end
				-- check args = "string"
				local argsNode = node.args
				local fileBody = nil
				if argsNode.__subtype=="string" then
					fileBody = argsNode.string
				elseif argsNode.__subtype=="(expr_list)" then
					local expr = argsNode.expr_list[1]
					if expr.__subtype == "value" then
						fileBody = expr.value.value
					end
				end

				if not fileBody then
					logger.error(node, "require's args not simple string...")
					return
				end

				fileBody = fileBody:gsub("[.]", "/")
				local subFileContext = globalContext:getFileContext(fileBody)
				if subFileContext then
					-- has bee parsed...
					node.__require = fileBody
				else
					-- parse it !!!
					local fileName = REQUIRE_PATH..fileBody..".lua"
					local parser = require "parser"
					local subFileContext = parser.parse(fileName, globalContext)
					if subFileContext then
						globalContext:setFileContext(fileBody, subFileContext)
						node.__require = fileBody

					else
						logger.error(node, fileBody.." require failed...")
					end
				end

			end
		}
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())
end
