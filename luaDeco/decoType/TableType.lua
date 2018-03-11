local class = require "util/oo"
local DecoType = require "luaDeco/decoType/DecoType"

local TableType = class(DecoType)

function TableType:toString()
	return "Table"
end

function TableType:contain(vObj)
	return TableType.isClass(vObj)
end

TableType.mInstance = TableType.new()

return TableType
