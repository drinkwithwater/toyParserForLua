local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local AstNode = require "astNode"

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
				local fileBody = AstNode.checkCallString(node, "require")
				if not fileBody then
					rawtravel(node)
					return
				end

				fileBody = fileBody:gsub("[.]", "/")
				local subFileContext = globalContext:getFileContext(fileBody)
				if subFileContext then
					-- has bee parsed...
					node.__require = fileBody
				else
					-- parse it !!!
					local parser = require "parser"
					local subFileContext = parser.parseStaticRequire(fileBody, globalContext)
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
