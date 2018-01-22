local cjson = require "cjson"
local idMeta = require "idMeta"

local function travelIDList(node)
	for k,v in pairs(node) do
		headIDDict[v] = 1
	end
end

local function nodeInfo(node)
	if type(node)=="table" then
		local a = node.__type .. ((node.__subtype and "."..node.__subtype) or "")
		local b = string.format("[%d,%d]", node.row, node.col)
		return b..a
	else
		return "id|"..node
	end
end

local function logWarning(node, ...)
	print("[WARNING]",node.__row,nodeInfo(node), ...)
end
local function logError(node, ...)
	print("[ERROR]",node.__row,nodeInfo(node), ...)
end
local travel = nil
local travelCheckType = function(node, vType)
	if not vType == node.__type then
		print(node.col, node.row, "type check error")
		print(vType, node.__type)
	else
		return travel(node)
	end
end
local travelCheckTypeSubType = function(node, vType, vSubType)
	if (not vType == node.__type) or (not vSubType == node.__subtype) then
		print(node.col, node.row, "sub type check error")
		print(vType, vSubType, node.__type, node.__subtype)
	else
		return travel(node)
	end
end

travelDict={
	stmt={
		["for"]=function(node)
			idMeta:getin()
			travelCheckType(node.head, "for_head")
			travelCheckType(node.block, "stmt_list")
			print("for node:", node.row, cjson.encode(idMeta:getLocalList()))
			idMeta:getout()
		end,
		["while"]=function(node)
			idMeta:getin()
			travelCheckType(node.head, "expr_list")
			travelCheckType(node.block, "stmt_list")
			print("while node:", node.row, cjson.encode(idMeta:getLocalList()))
			idMeta:getout()
			--print(nodeInfo(node), cjson.encode(idList))
		end,
		["local"]=function(node)
			if node.id_list then
				if node.expr_list then
					travel(node.expr_list)
				end
				for k,v in ipairs(node.id_list) do
					idMeta:setlocal(v, node)
				end
			elseif node.id then
				idMeta:setlocal(node.id, node)
				travel(node.argv)
				travel(node.block)
			end

			if node.deco_buffer then
				local inBuffer = node.deco_buffer:sub(4)
				local minusIndex = inBuffer:find("-")
				inBuffer=inBuffer:sub(1, minusIndex+1)
				-- subParser:parseScript(node.row, inBuffer)
			end
		end,
		["deco_declare"]=function(node)
			local inBuffer = node.buffer
			inBuffer = inBuffer:sub(6, #inBuffer-2)
			-- subParser:parseScript(node.row, inBuffer)
		end,
		["assign"]=function(node)
			travel(node.var_list)
			travel(node.expr_list)
			local varList = node.var_list
			local exprList = node.expr_list
			if #varList ~= #exprList then
				logWarning(node, "var list length ~= expr list length")
			else
				for i=1,#varList do
					local varNode = varList[i]
				end
			end
		end,
		--[[["function_call"]=function(node)
			error("TODO")
		end]]
	},
	for_head={
		["in"]=function(node)
			travel(node.expr)
			for k,v in ipairs(node.id_list) do
				idMeta:setlocal(v, node)
			end
		end,
		["eqa"]=function(node)
			travel(node.expr_list)
			idMeta:setlocal(node.id, node)
		end,
	},
	stmt_list=function(node)
		for k, subNode in ipairs(node) do
			-- print(nodeInfo(node))
			if subNode.__type == "stmt" and subNode.__subtype == "local" then
				travelCheckTypeSubType(subNode, "stmt", "local")
			else
				travelCheckType(subNode, "stmt")
			end
		end
	end,
	var_list=function(node)
		for k,v in ipairs(node) do
			travelCheckType(v, "var")
		end
	end,
	var={
		["id"]=function(node)
			if not idMeta:searchID(node.id) then
				print("undefined id:",cjson.encode(node))
			end
		end
	},
	expr={
		["value"]=function(node)
			travel(node.value)
			node.type_right = node.value.type_right
		end
	},
	value={
		["string"]=function(node)
			node.type_right="String"
		end,
		["number"]=function(node)
			node.type_right="Number"
		end,
		["true"]=function(node)
			node.type_right="Boolean"
		end,
		["false"]=function(node)
			node.type_right="Boolean"
		end,
		["nil"]=function(node)
			node.type_right="Nil"
		end,
	}

}

travel = function (node)
	local nType = node.__type
	local nSubType = node.__subtype
	if nType and nSubType and travelDict[nType] and travelDict[nType][nSubType] then
		return travelDict[nType][nSubType](node)
	elseif nType and not nSubType and travelDict[nType] then
		return travelDict[nType](node)
	else
		-- print(nType, nSubType, "not define")
		for k,v in pairs(node) do
			if type(v) == "table" then
				travel(v)
			end
		end
	end
end

return travel
