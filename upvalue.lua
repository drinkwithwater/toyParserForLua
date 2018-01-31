require "luaDeco/oo"

-- 一个local变量
local UpValue = class()

function UpValue:ctor(id, stmtNode, defineNode)
	self.id = id
	self.stmtNode = stmtNode
	self.defineNdoe = defineNode
end

function UpValue:getID()
	return self.id
end

local UpValueTable = class()
function UpValueTable:ctor(father, stmtNode)
	self.father = father
	self.stmtNode = stmtNode
	self.subList = {}
end

function UpValueTable:add(uv)
	self.subList[#self.subList + 1] = uv
end

local UpValueTree = class()

function UpValueTree:ctor(chunkNode)
	self.root = UpValueTable.new()
	self.curStmtNode = chunkNode
	self.curTable = UpValueTable.new(self.root, nil)
end

function UpValueTree:getin(stmtNode)
	local uvTable = UpValueTable.new(self.curTable, stmtNode)
	self.curStmtNode = stmtNode
	self.curTable = uvTable
end

function UpValueTree:getout(id, point)
end

