require "util/tableExpand"
local class = require "util/oo"


local BaseType = require "luaDeco/decoType/BaseType"
local AnyType = require "luaDeco/decoType/AnyType"
local TableType = require "luaDeco/decoType/TableType"

local Decorator = require "luaDeco/decorator/Decorator"

local decoTypeEnv = require "luaDeco/decoType/env"

decoTypeEnv.Number = BaseType.new("Number")
decoTypeEnv.String = BaseType.new("String")
decoTypeEnv.Boolean = BaseType.new("Boolean")
decoTypeEnv.Nil = BaseType.new("Nil")

decoTypeEnv.Any = AnyType.new()

decoTypeEnv.Table = TableType.new()

local temp = {
	Number = 1,
	String = 1,
	Boolean = 1,
	Nil = 1,
	Any = 1,
}

return table.map(temp, function(v,k)
	local nTypeIndex = decoTypeEnv[k]:getTypeIndex()

	local deco = Decorator.new()
	deco:setTypeIndex(nTypeIndex)

	return deco
end)

-- TODO
-- Table, Dot3

