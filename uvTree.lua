local class = require "luaDeco/oo"
local seri = require "seri"

---------------------------
-- TableValue -------------
-- used when id is table --
-- TODO not used ... ------
---------------------------
local TableValue = class()
function TableValue:ctor(name)
	self.name = name
	self.typeDict = {}
	self.valueDict = {}
end

function TableValue:getTypeDict()
	return self.typeDict
end

function TableValue:getValueDict()
	return self.valueDict
end

----------------------
-- UpValue -----------
----------------------
-- 一个local变量
local UpValue = class()

function UpValue:ctor(id, index)
	self.index = index
	self.subDict = {}
	if type(id) == "table" then
		if id.__type~="name" then
			error("parse error ... upvalue not name when uvTree:putid")
		end
		self.idNode = id
		self.name = id.name
	elseif type(id) == "string" then
		self.name = id
	end
end

function UpValue:getIndex()
	return self.index
end

function UpValue:getIDNode()
	return self.idNode
end

function UpValue:getName()
	return self.name
end

function UpValue:addKeyList(keyList)
	local point = self.subDict
	for k,v in ipairs(keyList) do
		if type(point[v])=="table" then
			point = point[v]
		else
			local newPoint = {}
			point[v] = newPoint
			point = newPoint
		end
	end
end

function UpValue:getSubDict()
	return self.subDict
end

function UpValue:isNative()
	if not self.idNode then
		return true
	else
		return false
	end
end

-----------------------
-- Table --------------
-----------------------
local UpValueTable = class()
function UpValueTable:ctor(father, point, stmtNode)
	self.father = father
	self.point = point
	self.stmtNode = stmtNode
	self.subList = {}
end

function UpValueTable:createChild(stmtNode)
	local point = #self.subList + 1
	local newTable = UpValueTable.new(self, point, stmtNode)
	self.subList[point] = newTable
	return newTable
end

function UpValueTable:addUpValue(uv)
	self.subList[#self.subList + 1] = uv
end

-- 在father中的索引
function UpValueTable:getPoint()
	return self.point
end

function UpValueTable:getFather()
	return self.father
end

function UpValueTable:search(name)
	for k=#self.subList,1,-1 do
		local cur = self.subList[k]
		if UpValue.isClass(cur) then
			if cur:getName() == name then
				return cur
			end
		end
	end
	if self.father then
		return self.father:search(name)
	end
end

function UpValueTable:show(i)
	for k,v in pairs(self.subList) do
		if UpValue.isClass(v) then
			print(string.rep("  ",i)..v:getName().." "..seri(v:getSubDict(),-1))
		else
			v:show(i+1)
		end
	end
end

-----------------------
-- Tree ---------------
-----------------------
local UpValueTree = class()

function UpValueTree:ctor(chunkNode, envTable)
	self.root = envTable or UpValueTable.new()
	self.curTable = self.root:createChild(chunkNode)
	self.firstTable = self.curTable
	self.uvIndexList = {}
end

function UpValueTree:getin(stmtNode)
	local uvTable = self.curTable:createChild(stmtNode)
	self.curTable = uvTable
end

function UpValueTree:putid(idNode)
	local newIndex = #self.uvIndexList + 1
	local uv = UpValue.new(idNode, newIndex)
	self.uvIndexList[newIndex] = uv
	self.curTable:addUpValue(uv)
	return newIndex
end

function UpValueTree:getout()
	self.curTable = self.curTable:getFather()
end

function UpValueTree:search(id)
	return self.curTable:search(id)
end

function UpValueTree.newDefault()
	local envTable = UpValueTable.new()
	local uvTree = UpValueTree.new(nil, envTable)
	for k,v in pairs(_G) do
		--local newIndex = #uvTree.uvIndexList + 1
		--local uv = UpValue.new(k, newIndex)
		--uvTree.uvIndexList[newIndex] = uv
		--envTable:addUpValue(uv)
	end
	return uvTree
end

function UpValueTree:show()
	self.root:show(0)
end

function UpValueTree:indexValue(index)
	return self.uvIndexList[index]
end

return UpValueTree
