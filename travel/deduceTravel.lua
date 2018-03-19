local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local decoTypeEnv = require "luaDeco/decoType/env"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("deduce", fileContext:getFileBody())
	local uvTree = fileContext:getUVTree()

	local decoEnv = fileContext:getFileDecoEnv():createGlobal(globalContext:getFileDecoEnvDict())

	local function setNodeDeduce(node, deduceType)
		if not node.__index then
			logger.warning(node, "node's uv index not found when deduce")
			return false
		end
		local uvValue = uvTree:indexValue(node.__index)
		if not uvValue then
			logger.warning(node, "node's uvValue not found when deduce")
			return false
		end
		uvValue:addKeyListDeduce(node.__key_list, deduceType)
		node.__type_right = deduceType
		return true
	end

	local travelDict={
		expr={
			["uop"]=function(node)
				travel(node.expr)
				local opStr = node.op.__subtype
				local type0 = node.expr.__type_right
				if not type0 then
					return
				end
				if opStr=="not" then
					node.__type_right = decoEnv.Boolean
				elseif opStr=="-" then
					--decoEnv.typeAssetWarning(decoEnv.Number, type0, cjson.encode(node))
					node.__type_right = decoEnv.Number
				elseif opStr=="#" then
					--decoEnv.typeAssetWarning(decoEnv.Table|decoEnv.String, type0, cjson.encode(node))
					node.__type_right = decoEnv.Number
				elseif opStr=="~" then
					--decoEnv.typeAssetWarning(decoEnv.Number, type0, cjson.encode(node))
					node.__type_right = decoEnv.Number
				else
					log.error(node,"unexception if branch")
				end
			end,
			["bop"]=function(node)
				travel(node.expr1)
				travel(node.expr2)
				local opStr = node.op.__subtype
				local type1 = node.expr1.__type_right
				local type2 = node.expr2.__type_right
				if not type1 or not type2 then
					return
				end
				if opStr=="or" or opStr=="and" then
					node.__type_right = type1 | type2
				elseif opStr=="+" or opStr=="-" or opStr=="*" or opStr=="/"
					or opStr=="^" or opStr=="%"
					or opStr=="|" or opStr=="&" or opStr=="~" then
					--decoEnv.typeAssetWarning(decoEnv.Number, type1, cjson.encode(node))
					--decoEnv.typeAssetWarning(decoEnv.Number, type2, cjson.encode(node))
					node.__type_right = decoEnv.Number
				elseif opStr=="==" or opStr=="~=" then
					node.__type_right = decoEnv.Boolean
				elseif opStr==">=" or opStr=="<=" or opStr==">" or opStr=="<" then
					--decoEnv.typeAssetWarning(decoEnv.Number, type1, cjson.encode(node))
					--decoEnv.typeAssetWarning(decoEnv.Number, type2, cjson.encode(node))
					node.__type_right = decoEnv.Boolean
				elseif opStr==".." then
					--decoEnv.typeAssetWarning(decoEnv.String, type1, cjson.encode(node))
					--decoEnv.typeAssetWarning(decoEnv.String, type2, cjson.encode(node))
					node.__type_right = decoEnv.String
				else
					logger.error(node,"TODO if branch",opStr)
				end
			end,
			["value"]=function(node)
				travel(node.value)
				node.__type_right = node.value.__type_right
			end,
			["prefix_exp"]=function(node)
				travel(node.prefix_exp)
				node.__type_right = node.prefix_exp.__type_right
			end,
		},
		var=function(node)
			if node.__index then
				local uvValue = uvTree:indexValue(node.__index)
				if uvValue then
					local decoClass = uvValue:getKeyListDeco(node.__key_list)
					if decoClass then
						node.__type_right = decoClass
					end
				end
			end
		end,
		stmt={
			["function_call"]=function(node)
				travel(node.args)
				travel(node.prefix_exp)
				if node.__index then
					local uvValue = uvTree:indexValue(node.__index)
					if uvValue then
						local decoClass = uvValue:getKeyListDeco(node.__key_list)
						if decoClass then
							-- TODO get return value from function...
						end
					end
				end
			end,
			-- three stmt may cause deduce to upvalue
			["assign"]=function(node)
				travel(node.expr_list)
				for k, var in ipairs(node.var_list) do
					local expr = node.expr_list[k]
					if expr and expr.__type_list then
						setNodeDeduce(var, expr.__type_list)
					else
						setNodeDeduce(var, decoTypeEnv.Nil)
					end
				end
			end,
			["function"]=function(node)
				travel(node.block)
				-- deco node.var_function
				local func = decoTypeEnv.FunctionType.new()
				local argv = node.argv
				if argv.__subtype == "()" then
					func:setArgTuple({})
				elseif argv.__subtype == "list" then
					local list = {}
					for k,v in ipairs(argv.name_list) do
						list[#list + 1] = decoTypeEnv.Any
					end
					func:setArgTuple(list)
				else
					print("TODO")
				end
				node.__type_right = func
				setNodeDeduce(node.var_function, func)
			end,
			["local"]=function(node)
				if node.expr_list then
					travel(node.expr_list)
					for k,expr in ipairs(node.expr_list) do
						if expr.__subtype=="lambda" then
							local lambda = expr.lambda
							if lambda.__type_right then
								setNodeDeduce(node.name_list[k], lambda.__type_right)
							end
						end
					end
				end
			end
		},
		value={
			["string"]=function(node)
				node.__type_right = decoTypeEnv.String
			end,
			["number"]=function(node)
				node.__type_right = decoTypeEnv.Number
			end,
			["true"]=function(node)
				node.__type_right = decoTypeEnv.Boolean
			end,
			["false"]=function(node)
				node.__type_right = decoTypeEnv.Boolean
			end,
			["nil"]=function(node)
				node.__type_right = decoTypeEnv.Nil
			end,
		},
		function_lambda=function(node)
			travel(node.argv)
			travel(node.block)
			local func = decoTypeEnv.FunctionType.new()
			local argv = node.argv
			if argv.__subtype == "()" then
				func:setArgTuple({})
			elseif argv.__subtype == "list" then
				local list = {}
				for k,v in ipairs(argv.name_list) do
					list[#list + 1] = decoTypeEnv.Any
				end
				func:setArgTuple(list)
			else
				-- TODO
			end
			node.__type_right = func
		end
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	local ast = fileContext:getAST()
	travel(ast)
	local retNode = fileContext:getLastAstNode()
	if retNode and retNode.__subtype=="return" then
		if retNode.expr_list and #retNode.expr_list >= 1 then
			local retType = retNode.expr_list[1].__type_right
			if retType then
				fileContext:getFileDecoEnv():setRetType(retType)
			end
		end
	end
end
