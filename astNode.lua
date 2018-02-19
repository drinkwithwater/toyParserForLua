local class = require "luaDeco/oo"
local AstNode = class()

function AstNode.ctor()
	-- item add by c
	self.__type = nil
	self.__subtype = nil
	self.__col = nil
	self.__row = nil

	-- item add by lua
	self.__type_right = nil
	self.__type_left = nil
	self.__index = nil
end
