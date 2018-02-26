local cjson = require "cjson"
local NodeLogger = require "nodeLogger"

-- TODO set this as local
local decoEnv = require "luaDeco/env"

return function(fileContext, globalContext)
	local ast = fileContext:getAST()
	local uvTree = fileContext:getUVTree()
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("decoTravel")

	local function parseDecoBuffer(buffer)
		local first = buffer:find("@")
		local last = buffer:find(";") or #buffer+1
		local content = buffer:sub(first+1,last-1)
		local block = load("return "..content, "deco", "t", decoEnv)
		local ok, decoClass = pcall(block)
		if ok then
			return decoClass
		else
			return nil
		end
	end

	local function setNodeDeco(decoNode, decoClass)
		if not decoNode.__index then
			logger.error(decoNode, "node's uv index not found when deco")
			return false
		end
		local uvValue = uvTree:indexValue(decoNode.__index)
		if not uvValue then
			logger.error(decoNode, "node's uvValue not found when deco")
			return false
		end
		uvValue:setKeyListDeco(decoNode.__key_list, decoClass:decorator(decoNode))
		decoNode.__type_left = decoClass
		return true
	end
	local function setArgvDeco(argvNode, funcDecoClass)
		local argTypeTuple = funcDecoClass:getArgTuple()
		if argvNode.__subtype=="list" then
			local nameList = argvNode.name_list
			if #argTypeTuple ~= #nameList then
				logger.error(node, "argv size exception")
				return false
			end
			for k, argType in pairs(argTypeTuple) do
				setNodeDeco(nameList[k], argType)
			end
		elseif argvNode.__subtype=="()" then
			if #argTypeTuple~=0 then
				logger.error(node, "argv size exception")
				return false
			end
		else
			logger.error(argvNode, "this version only support list and empty argv in function stmt")
			return false
		end
		return true
	end

	local travelDict={
		stmt={
			["deco_declare"]=function(node)
				-- TODO
				-- print(node.buffer)
			end,
			["local"]=function(node)
				local buffer = node.deco_buffer
				if not buffer then
					-- normal local stmt, do nothing
					return
				end
				local decoClass = parseDecoBuffer(buffer)
				if not decoClass then
					logger.error(node, "decorating failed")
					return
				end
				if node.name_list then  -- not function..
					if #node.name_list ~= 1 then
						logger.error(node, "this version only support 1 identifier in local stmt")
						return
					end
					local decoNode = node.name_list[1]
					setNodeDeco(decoNode, decoClass)
				elseif node.name then   -- function..
					-- deco node.name
					setNodeDeco(node.name, decoClass)
					-- deco node.argv
					setArgvDeco(node.argv, decoClass)
					travel(node.block)
					-- TODO check return ...
				end
			end,
			["assign"]=function(node)
				local buffer = node.deco_buffer
				if not buffer then
					-- normal local stmt, do nothing
					return
				end
				local decoClass = parseDecoBuffer(buffer)
				if not decoClass then
					logger.error(node, "decorating failed")
					return
				end
				if #node.var_list ~= 1 then
					logger.error(node, "this version only support one var in assign stmt")
					return
				end
				local decoNode = node.var_list[1]
				setNodeDeco(decoNode, decoClass)
			end,
			["function"]=function(node)
				local buffer = node.deco_buffer
				if not buffer then
					-- normal local stmt, do nothing
					return
				end
				local decoClass = parseDecoBuffer(buffer)
				if not decoClass then
					logger.error(node, "decorating failed")
					return
				end
				-- deco node.var_function
				setNodeDeco(node.var_function, decoClass)
				-- deco node.argv
				setArgvDeco(node.argv, decoClass)
				travel(node.block)
				-- TODO check return ...
			end
		},
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(ast)
end
