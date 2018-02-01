local class = require "luaDeco/oo"

-- 一个local变量
local UpValue = class()

function UpValue:ctor(id, defineNode)
	self.id = id
	self.defineNdoe = defineNode
end

function UpValue:getID()
	return self.id
end

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
			if cur:getID() == id then
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
			print(string.rep("  ",i)..v:getID())
		else
			v:show(i+1)
		end
	end
end

local UpValueTree = class()

function UpValueTree:ctor(chunkNode, envTable)
	self.root = envTable or UpValueTable.new()
	self.curTable = self.root:createChild(chunkNode)
	self.firstTable = self.curTable
end

function UpValueTree:getin(stmtNode)
	local uvTable = self.curTable:createChild(stmtNode)
	self.curTable = uvTable
end

function UpValueTree:putid(id, defineNode)
	local uv = UpValue.new(id, defineNode)
	self.curTable:addUpValue(uv)
end

function UpValueTree:getout()
	self.curTable = self.curTable:getFather()
end

function UpValueTree:search(id)
	return self.curTable:search(id)
end

function UpValueTree.newDefault()
	local envTable = UpValueTable.new()
	for k,v in pairs(_G) do
		local uv = UpValue.new(k,nil)
		envTable:addUpValue(uv)
	end
	return UpValueTree.new(nil, envTable)
end

function UpValueTree:show()
	self.root:show(0)
end

return UpValueTree
