local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local AstNode = require "astNode"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("test", fileContext:getFileBody())

	local travelDict={
		stmt={
			["function_call"]=function(node)
				local ok, arg = AstNode.checkCallString(node, "require")
				if ok then
					print("require", arg)
					return
				end
				local ok, arg = AstNode.checkCallString(node, "soa", "uniqueservice")
				if ok then
					print("soa.uniqueservice", arg)
					return
				end
				local ok, arg = AstNode.checkCallString(node, "soa", "newservice")
				if ok then
					print("skynet.newservice", arg)
					return
				end
				local ok, arg = AstNode.checkCallString(node, "skynet", "uniqueservice")
				if ok then
					print("skynet.uniqueservice", arg)
					return
				end
				rawtravel(node)
			end,

		},

	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())

end
