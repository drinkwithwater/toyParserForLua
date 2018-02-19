local class = require "luaDeco/oo"

----------------------
-- UpValue -----------
----------------------
-- 一个local变量
local UpValue = class()

function UpValue:ctor(id, index)
	self.index = index
	if type(id) == "table" then
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

function UpValueTable:search(id)
	for k=#self.subList,1,-1 do
		local cur = self.subList[k]
		if UpValue.isClass(cur) then
			if cur:getName() == id then
				return cur
			end
		end
	end
	if self.father then
		return self.father:search(id)
	end
end

function UpValueTable:show(i)
	for k,v in pairs(self.subList) do
		if UpValue.isClass(v) then
			print(string.rep("  ",i)..v:getName())
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

return UpValueTree
