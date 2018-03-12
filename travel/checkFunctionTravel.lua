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

				local argsNode = node.args
				local argTuple = decoType:getArgTuple()
				if not argTuple then
					log.warning(node, "simple function...")
					return
				end

				if argsNode.__subtype=="string" then
					if #argTuple ~= 1 then
						log.error(node, "function check failed 1")
					else
						local argType = argTuple[1]
						if argType:toString() ~= "String" then
							log.error(node, "function check failed 2")
						end
					end
				elseif argsNode.__subtype=="table" then
					if #argTuple ~= 1 then
						log.error(node, "function check failed 3")
					else
						local argType = argTuple[1]
						if argType:toString() ~= "String" then
							log.error(node, "function check failed 4")
						end
					end
				elseif argsNode.__subtype=="()" then
					if #argTuple ~= 0 then
						log.error(node, "function check failed 5")
					end
				elseif argsNode.__subtype=="(expr_list)" then
					if #argTuple ~= #argsNode.expr_list then
						log.error(node, "function check failed 6")
					else
						for k, argType in ipairs(argTuple) do
							local exprNode = argsNode.expr_list[k]
							local rightType = exprNode.__type_right
							if exprNode.__index then
								rightType = uvTree:indexValue(exprNode.__index):getKeyListDeco(exprNode.__key_list)
							end
							if rightType then
								if not (argType>=rightType) then
									log.error(node, "function check failed 7")
								end
							else
								log.error(node,"function check failed 8")
							end
						end
					end
				else
				end
				if argTuple then
				end
				log.result(node, "function check end")
			end
		}
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())
end
