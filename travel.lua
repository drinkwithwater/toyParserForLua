local cjson = require "cjson"
local subParser = require "sub/subParser"
local idDictStack = {}

local function headIDDict()
	return idDictStack[#idDictStack]
end

local function newIDDict()
	local idDict = {}
	idDictStack[#idDictStack + 1] = idDict
	return idDict
end
local function popIDDict()
	local idDict = idDictStack[#idDictStack]
	idDictStack[#idDictStack] = nil
	return idDict
end

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
			local idList = {}
			local list1 = travelCheckType(node.head, "for_head")
			local list2 = travelCheckType(node.block, "stmt_list")
			for k,v in pairs(list1) do
				idList[#idList + 1] = v
			end
			for k,v in pairs(list2) do
				idList[#idList + 1] = v
			end
			print(nodeInfo(node), cjson.encode(idList))
		end,
		["while"]=function(node)
			local list = travelCheckType(node.head, "stmt_list")
			print(nodeInfo(node), cjson.encode(idList))
		end,
		["local"]=function(node)
			local idList = {}
			if node.id_list then
				for k,v in ipairs(node.id_list) do
					idList[#idList + 1] = v
				end
				if node.expr_list then
					travel(node.expr_list)
				end
			elseif node.id then
				idList = {node.id}
				travel(node.argv)
				local subList = travel(node.block)
				print(nodeInfo(node.block), cjson.encode(subList))
			end

			if node.deco_buffer then
				local inBuffer = node.deco_buffer:sub(4)
				local minusIndex = inBuffer:find("-")
				inBuffer=inBuffer:sub(1, minusIndex+1)
				print("============= deco" , inBuffer)
				subParser:parseScript(node.row, inBuffer)
			end
			return idList
		end,
		["deco_declare"]=function(node)
			local inBuffer = node.buffer
			inBuffer = inBuffer:sub(6, #inBuffer-2)
			print("============= declare" , inBuffer)
			subParser:parseScript(node.row, inBuffer)
		end
	},
	for_head={
		["in"]=function(node)
			local idList = {}
			for k,v in ipairs(node.id_list) do
				idList[#idList + 1] = v
			end
			travel(node.expr)
			return idList
		end,
		["eqa"]=function(node)
			local idList = {node.id}
			travel(node.expr_list)
			return idList
		end,
	},
	stmt_list=function(node)
		local idList = {}
		for k,subNode in ipairs(node) do
			-- print(nodeInfo(node))
			if subNode.__type == "stmt" and subNode.__subtype == "local" then
				local list = travelCheckTypeSubType(subNode, "stmt", "local")
				for k,v in pairs(list) do
					idList[#idList + 1] = v
				end
			else
				travelCheckType(subNode, "stmt")
			end
		end
		return idList
	end,
	var_list=function(node)
		for k,v in ipairs(node) do
			travelCheckType(v, "var")
		end
	end,
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
