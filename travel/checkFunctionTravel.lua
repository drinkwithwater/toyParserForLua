local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local FunctionType = require "luaDeco/decoType/FunctionType"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local log = NodeLogger.new("check")
	local uvTree = fileContext:getUVTree()

	local travelDict={
		stmt={
			["function_call"]=function(node)
				local rightType = node.__type_right
				if rightType then
					--TODO
				end
				local leftType = node.__type_left
				if leftType then
					--TODO
				end

				if not node.__index then
					log.warning(node, "function no upvalue index found...")
					return
				end
				local uv = uvTree:indexValue(node.__index)
				local decoType = uv:getKeyListDeco(node.__key_list)
				if not decoType then
					log.warning(node, "function no decoType found...")
					return
				end

				if not FunctionType.isClass(decoType) then
					log.error(node, "function_call's upvalue is not function type ...")
					return
				end

				-- TODO check arguments

				local argTuple = decoType:getArgTuple()
				if argTuple then
					for k, argDecoType in pairs(argTuple) do
						-- TODO check arguments
					end
				end
				log.result(node, "function check success")
			end
		}
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())
end
