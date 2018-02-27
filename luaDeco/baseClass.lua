local typeClass = require "luaDeco/typeClass"

local SimpleType = typeClass.SimpleType

local Number = SimpleType.new("Number")
local String = SimpleType.new("String")
local Table = SimpleType.new("Table")
local Boolean = SimpleType.new("Boolean")
local Nil = SimpleType.new("Nil")
local Dot3 = SimpleType.new("Dot3")

local Interface = function(table)
end

local Call=function(...)
	local nFunction = typeClass.FunctionType.new()
	nFunction:setArgTuple(...)
	return {
		Return = function(...)
			nFunction:setRetTuple(...)
			return nFunction
		end
	}
end

local Class = {}

function Class:decorator(node, upValue)
	return typeClass.ClassType.new()
end



-- Call(Number, String, Father).Return(Phone)

-- local sth = Call(Number, String, Interface {d=Number, dosth=String} ).Return(nil)
-- print(seri(sth))

local dict = {
	String=String,
	Number=Number,
	Table=Table,
	Boolean=Boolean,
	Nil=Nil,
	Call=Call,
	Dot3=Dot3,
	Class=Class,
}

return dict
