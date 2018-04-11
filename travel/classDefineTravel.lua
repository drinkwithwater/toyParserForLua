local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local AstNode = require "astNode"
local embed = require "luaDeco/embed"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("classDefine", fileContext:getFileBody())

	local uvTree = fileContext:getUVTree()

	local function checkExprClass(expr)
		local funcCall = AstNode.checkExprCall(expr)
		if not funcClass then
			return false
		end
		local args = AstNode.checkCallArgs(funcCall, "class")
		if not args then
			return false
		else
			return true
		end
	end

	local travelDict={
		stmt={
			["local"]=function(node)
				rawtravel(node)
				if not node.expr_list then
					return
				end
				if #node.expr_list ~= 1 then
					return
				end

				local nameNode = node.name_list[1]
				local name = nameNode.name

				if not checkExprClass(node.expr_list[1]) then
					return
				else
					local upvalue = uvTree:indexValue(nameNode.__index)
					local classEmbed = embed.ClassEmbed.new(fileContext, globalContext, logger)
					classEmbed:setDefine(name, upvalue)
					local protoType = classEmbed:getClassProto()
					upvalue:setKeyListNative({}, protoType)
				end
			end,
			["assign"]=function(node)
				rawtravel(node)
				-- TODO
				-- Sth.SubSth
			end
		},

	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())

end
