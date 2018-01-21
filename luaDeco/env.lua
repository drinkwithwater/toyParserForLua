local seri = require "seri"
local typeClass = require "typeClass"

local SimpleType = typeClass.SimpleType
local FunctionType = typeClass.FunctionType

Number = SimpleType.new("Number")
String = SimpleType.new("String")
Table = SimpleType.new("Table")
Boolean = SimpleType.new("Boolean")
Nil = SimpleType.new("Nil")
Dot3 = SimpleType.new("Dot3")

Function = FunctionType.new()

Interface = function(table)
end

Call=function(...)
	local nFunction = FunctionType.new()
	nFunction:setArgTuple(...)
	return {
		Return = function(...)
			nFunction:setRetTuple(...)
			return nFunction
		end
	}
end



-- Call(Number, String, Father).Return(Phone)

Call(Number, String, Interface {d=Number, dosth=String} ).Return(Phone)

