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
				local fileBody = nil
				local serviceType = nil
				for k, tuple in pairs(nativeList) do
					fileBody = AstNode.checkCallString(node, tuple[1], tuple[2])
					if fileBody then
						serviceType = tuple[1]
						break
					end
				end
				if not fileBody then
					rawtravel(node)
					return
				end

				fileBody = fileBody:gsub("[.]", "/")
				local skynetService = globalContext:getService(fileBody)
				if skynetService then
					return
				end


				--TTTTTTTTTTTTTTTTTTTTTT TODO
				if fileBody == "debug_console" then
					-- TODO
					print(" syntax don't has repeat stmt !!!!!! in debug_console.lua ")
					return
				end
				--TTTTTTTTTTTTTTTTTTTTTT TODO


				local parser = require "parser"
				local fileContext = nil
				if serviceType=="skynet" then
					fileContext = parser.parseSkynetInclude(fileBody, globalContext, false)
				elseif serviceType=="soa" then
					fileContext = parser.parseSkynetInclude(fileBody, globalContext, true)
				end

				local service = fileContext:getService()
				if skynetService then
					globalContext:setService(fileBody, service)
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
