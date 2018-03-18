local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local AstNode = require "astNode"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("skynetInclude", fileContext:getFileBody())

	local uvTree = fileContext:getUVTree()

	local travelDict={
		stmt={
			["function_call"]=function(node)
				local nativeList = {
					{"soa", "uniqueservice"},
					{"skynet", "uniqueservice"},
					{"skynet", "newservice"},
				}
				local ok, fileBody = false, nil
				for k, tuple in pairs(nativeList) do
					ok, fileBody = AstNode.checkCallString(node, tuple[1], tuple[2])
					if ok then
						break
					end
				end
				if not ok then
					rawtravel(node)
					return
				end

				local skynetService = globalContext:getService(fileBody)
				if skynetService then
					return
				end

				local parser = require "parser"
				local fileContext = parser.parseSkynetInclude(fileBody..".lua", globalContext)
				skynetService = fileContext:getService()
				if skynetService then
					globalContext:setService(fileBody, skynetService)
				else
					logger.warning(node, "skynet service undefined")
				end
			end,
		},

	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())

end
