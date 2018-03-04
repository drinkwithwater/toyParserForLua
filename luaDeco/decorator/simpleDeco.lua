local class = require "util/oo"
local Decorator = require "luaDeco/decorator/Decorator"

local BaseType = require "luaDeco/decoType/BaseType"

local SimpleDeco = class(Decorator)

function SimpleDeco:ctor(str)
	local baseType = BaseType.new(str)
	self.mTypeIndex = baseType:getTypeIndex()
end

local Number = SimpleDeco.new("Number")
local String = SimpleDeco.new("String")
local Table = SimpleDeco.new("Table")
local Boolean = SimpleDeco.new("Boolean")
local Nil = SimpleDeco.new("Nil")
local Dot3 = SimpleDeco.new("Dot3")

return {
	Number = Number,
	String = String,
	Table = Table,
	Nil = Nil,
	Boolean = Boolean,
}

