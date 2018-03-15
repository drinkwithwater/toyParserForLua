local class = require "util/oo"
local seri = require "seri"
local uvSubSeri= require "uvSubSeri"
local cjson = require "cjson"

local DecoSubDict = require "util/keyListDict"

----------------------
-- UpValue -----------
----------------------
-- 一个local变量
local UpValue = class()

--@Call(Table, Number).Return()
function UpValue:ctor(id, index)
	self.index = index					--@Number ;
	self.subDict = {}					--@Table ;
--	self.decoSubDict = DecoSubDict.new()
--	self.deduceSubDict = DecoSubDict.new()
	self.typeListDict = DecoSubDict.new()
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

--@Call().Return(Number)
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

function UpValue:setKeyListDeco(keyList, decoClass)
	self.typeListDict:setKeyListValue(keyList, decoClass, 2)
end

function UpValue:getKeyListDeco(keyList)
	return self.typeListDict:getKeyListValue(keyList, 2)
end

function UpValue:addKeyListDeduce(keyList, deduceClass)
	local list = self.typeListDict:getKeyListValue(keyList, 3)
	if not list then
		list = {}
		self.typeListDict:setKeyListValue(keyList, list, 3)
	end
	list[#list + 1] = deduceClass
end

function UpValue:getSubDict()
	return self.subDict
end

function UpValue:getTypeListDict()
	return self.typeListDict
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
			print(string.rep("  ",i)..v:getName().."="..uvSubSeri(v:getTypeListDict(), i))
			-- print(string.rep("  ",i)..v:getName().." "..cjson.encode(v:getDecoSubDict()))
			-- print(string.rep("  ",i)..v:getName().." "..seri(v:getSubDict(), -1))
		else
			v:show(i+1)
		end
	end
end

-----------------------
-- Tree ---------------
-----------------------
--@Class
local UpValueTree = class()

function UpValueTree:ctor(globalValue)
	self.globalValue = globalValue
	self.curTable = UpValueTable.new()
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

function UpValueTree.createGlobalValue()
	local globalValue = UpValue.new("_G", -1)
	return globalValue
end

function UpValueTree:show()
	self.root:show(0)
end

function UpValueTree:indexValue(index)
	return self.uvIndexList[index]
end

UpValueTree.DecoSubDict = DecoSubDict
return UpValueTree
