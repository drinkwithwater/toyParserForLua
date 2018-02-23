local class = require "luaDeco/oo"
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
end

AstNode.ID_OPER_DEF = 1
AstNode.ID_OPER_SET = 2
AstNode.ID_OPER_GET = 3

return AstNode
