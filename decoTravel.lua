local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local decoEnv = require "luaDeco/env"

return function(ast)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("decoTravel")

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
				local first = buffer:find("@")
				local last = buffer:find("!")
				local content = buffer:sub(first+1,last-1)
				local block = load("return "..content, "deco", "t", decoEnv)
				if node.name_list then
					if #node.name_list ~= 1 then
						logger.error(node, "this version only support 1 identifier in local stmt")
						return
					else
						local decoNode = node.name_list[1]
						decoNode.__type_left = block()
					end
				elseif node.name then
					local decoNode = node.name
					local funcType = block()
					-- deco node.name
					decoNode.__type_left = funcType
					-- deco node.argv.name_list
					local argTypeTuple = funcType:getArgTuple()
					if node.argv.__subtype=="list" then
						local nameList = node.argv.name_list
						if #argTypeTuple ~= #nameList then
							logger.error(node, "argv num exception")
							return
						end
						for k,v in pairs(argTypeTuple) do
							nameList[k].__type_left = v
						end
					elseif node.argv.__subtype=="()" then
						if #argTypeTuple~=0 then
							logger.error(node, "not function not dosth")
							return
						end
					else
						logger.error(node, "this version only support list and empty argv in function stmt")
						return
					end
					-- TODO check return ...
				end
			end,
			["assign"]=function(node)
				local buffer = node.deco_buffer
				if not buffer then
					-- normal local stmt, do nothing
					return
				end
				-- TODO
			end,
			["function"]=function(node)
				local buffer = node.deco_buffer
				if not buffer then
					-- normal local stmt, do nothing
					return
				end
				-- TODO
			end
		},
	}

	local travelFactory = require "travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(ast)
end
