local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local decoEnv = require "luaDeco/env"

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
			if node.id_list then
				if #node.id_list ~= 1 then
					logger.error(node, "this version only support 1 identifier in local stmt")
					return
				else
					local decoNode = node.id_list[1]
					decoNode.__type_left = block()
				end
			elseif node.id then
				local decoNode = node.id
				local funcType = block()
				-- deco node.id
				decoNode.__type_left = funcType
				-- deco node.argv.id_list
				local argTypeTuple = funcType:getArgTuple()
				if node.argv.__subtype=="list" then
					local idList = node.argv.id_list
					if #argTypeTuple ~= #idList then
						logger.error(node, "argv num exception")
						return
					end
					for k,v in pairs(argTypeTuple) do
						idList[k].__type_left = v
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

return travel
