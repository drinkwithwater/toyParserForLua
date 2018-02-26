local cjson = require "cjson"
local NodeLogger = require "nodeLogger"

return function(ast, uvTree)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("autoDecoTravel")

	local travelDict={
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(ast)
end
