local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local decoTypeEnv = require "luaDeco/decoType/env"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("deduce")
	local uvTree = fileContext:getUVTree()

	local decoEnv = fileContext:getFileDecoEnv():createGlobal(globalContext:getFileDecoEnvDict())

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
					log.error(node,"unexception if branch")
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
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	local ast = fileContext:getAST()
	travel(ast)
	local retNode = ast[#ast]
	if retNode and retNode.__subtype=="return" and #retNode.expr_list >= 1 then
		local retType = retNode.expr_list[1].__type_right
		if retType then
			fileContext:getFileDecoEnv():setRetType(retType)
		end
	end
end
