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

function AstNode.checkCallString(node, name, subName)
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


	-- check args = "string"
	local argsNode = node.args
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

function AstNode.checkReturnName(node)
	if node.__subtype ~= "return" then
		return false
	end

	if not node.expr_list then
		return false
	end

	local expr = lastAstNode.expr_list[1]
	if expr.__subtype ~= "prefix_expr" then
		return false
	end

	local preVar = expr.prefix_exp
	if preVar.__type=="var" and preVar.__subtype=="name" then
		return preVar.name.name
	else
		return false
	end

end

AstNode.ID_OPER_DEF = 1
AstNode.ID_OPER_SET = 2
AstNode.ID_OPER_GET = 3

return AstNode
