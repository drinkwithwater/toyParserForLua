local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local AstNode = require "astNode"
local embed = require "luaDeco/embed"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("declare", fileContext:getFileBody())
	local fileEnv = fileContext:getFileDecoEnv()
	local uvTree = fileContext:getUVTree()

	local function checkNodeDeco(node)
		local buffer = node.buffer
		if not buffer then
			return false
		elseif buffer:sub(1,5) == "--[[@" then
			return buffer
		else
			return false
		end
	end

	local travelDict={
		stmt={
			["deco_declare"]=function(node)
				local buffer = checkNodeDeco(node)
				if not buffer then
					return
				end
				-- parse from buf
				local first = buffer:find("@") + 1
				local last = #buffer - 2
				local content = buffer:sub(first, last)
				-- load
				local block = load(content, "declare", "t", fileEnv:getDeclareEnv())
				local ok, result = pcall(block)
				if not ok then
					logger.error(node, "declare failed...", result)
				end
			end,
			["assign"]=function(node)
				-- TODO not used in assign ...
				--[[
				if #node.var_list~=1 or #node.expr_list~=1 then
					rawtravel(node)
					return
				end

				-- check var
				local var=node.var_list[1]
				if var.__subtype~="name" then
					rawtravel(node)
					return
				end

				-- check expr
				local requireFile = AstNode.checkCallString(node.expr_list[1], "require")
				if not requireFile then
					rawtravel(node)
					return
				end

				fileContext:getFileDecoEnv():addRequire(var.name.name, requireFile) ]]
			end,
			["local"]=function(node)
				if not node.name_list or not node.expr_list then
					rawtravel(node)
					return
				end

				if #node.name_list~=1 or #node.expr_list~=1 then
					rawtravel(node)
					return
				end

				-- check name
				local nameNode=node.name_list[1]

				-- if is require
				local requireFileBody = AstNode.checkExprCallString(node.expr_list[1], "require")
				local classArgs, sth = AstNode.checkExprCallArgs(node.expr_list[1], "class")
				if requireFileBody then
					fileContext:getFileDecoEnv():addRequire(nameNode.name, requireFileBody)
				elseif classArgs then
					local upvalue = uvTree:indexValue(nameNode.__index)
					local classEmbed = embed.ClassEmbed.new(fileContext, globalContext, logger)
					classEmbed:setDefine(nameNode.name, upvalue)
					local protoType = classEmbed:getClassProto()
					upvalue:setKeyListNative({}, protoType)
				else
					rawtravel(node)
				end
			end,
		}
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())
end
