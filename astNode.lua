local class = require "util/oo"
local AstNode = class()

function AstNode:ctor()
	-- item add by c
	self.__type = nil
	self.__subtype = nil
	self.__col = nil
	self.__row = nil

	-- item for type
	self.__type_right = nil
	self.__type_left = nil

	-- item for id
	self.__index = nil

	-- item for a.b.c...
	self.__key_list = nil

	-- item for function_call
	self.__require = nil
end

-- type == expr.prefix_exp-var,name
function AstNode.checkExprName(node)
	-- check node is (expr,prefix_exp)
	if node.__type ~= "expr" or node.__subtype ~= "prefix_exp" then
		return false
	end

	-- check node.prefix_exp is (var,name)
	local preVar = node.prefix_exp
	if preVar.__type~="var" or preVar.__subtype~="name" then
		return false
	end

	return preVar.name.name
end

-- type == expr.value
function AstNode.checkExprString(node)
	-- check node is (expr,value)
	if node.__type ~= "expr" or node.__subtype ~= "value" then
		return false
	end

	return node.value.value
end

-- type == expr.prefix_exp-function_call
function AstNode.checkExprCall(node)
	-- check node is (expr,value)
	if node.__type ~= "expr" or node.__subtype ~= "prefix_exp" then
		return false
	end

	return node.prefix_exp
end

-- soa  soa.uniqueservice
function AstNode.checkCall(node, name, subName)
	if node.__subtype ~= "function_call" then
		return false
	end
	if node.name then
		return false
	end
	-- check prefix_exp = require
	local funcVar = node.prefix_exp
	if funcVar.__type~="var" then
		return false
	end


	if type(name)~="string" then
		error("name must be string")
	end


	if type(subName)=="string" then
		if funcVar.__subtype~=".name" then
			return false
		end
		local preFuncVar = funcVar.prefix_exp
		if preFuncVar.__type~="var" or preFuncVar.__subtype~="name" then
			return false
		end
		if preFuncVar.name.name ~= name then
			return false
		end
		if funcVar.name.name ~= subName then
			return false
		end
	elseif not subName then
		if funcVar.__subtype~="name" then
			return false
		end
		local nameNode = funcVar.name
		if nameNode.name ~= name then
			return false
		end
	else
		error("subName must be string or nil")
	end

	return node.args
end

-- require("dosth")   require "dosth"
function AstNode.checkCallString(node, name, subName)
	-- check args = "string"
	local argsNode = AstNode.checkCall(node, name, subName)
	if not argsNode then
		return false
	end
	local retArg = nil
	if argsNode.__subtype=="string" then
		retArg = argsNode.string
	elseif argsNode.__subtype=="(expr_list)" then
		local expr = argsNode.expr_list[1]
		if expr.__subtype == "value" then
			retArg = expr.value.value
		end
	end

	if retArg then
		return retArg
	else
		return false
	end
end

function AstNode.checkCallName(node)
	-- check args = "string"
	local argsNode = AstNode.checkCall(node, name, subName)
	if not argsNode then
		return false
	end
	if argsNode.__subtype~="(expr_list)" then
		return false
	end

	local expr = argsNode.expr_list[1]
	return AstNode.checkExprName(expr)
end

function AstNode.checkReturnName(node)
	if node.__subtype ~= "return" then
		return false
	end

	if not node.expr_list then
		return false
	end

	local expr = node.expr_list[1]
	return AstNode.checkExprName(expr)
end


AstNode.ID_OPER_DEF = 1
AstNode.ID_OPER_SET = 2
AstNode.ID_OPER_GET = 3

return AstNode
