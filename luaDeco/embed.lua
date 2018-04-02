local class = require "util/oo"
local SkynetType = require "luaDeco/decoType/SkynetType"
local FunctionType = require "luaDeco/decoType/FunctionType"

local SkynetEmbed = class()

function SkynetEmbed:ctor(fileContext, globalContext, logger)
	self.mSkynetType = SkynetType.new()

	self.fileContext = fileContext
	self.globalContext = globalContext
	self.logger = logger
end

function SkynetEmbed:__call(...)
	local list = table.pack(...)
	local subcmd
	local upvalue
	if #list == 2 then
		subcmd, upvalue = ...
	elseif #list==1 then
		upvalue = ...
		subcmd = nil
	end
	if #list>2 then
		self.logger.print("error, skynet not support more than 2 layer subcmd...!!!")
	elseif #list<1 then
		self.logger.print("error, skynet not support less than 1 layer subcmd...!!!")
	end

	local subNodeDict = upvalue:getTypeListDict()[1]

	for lastKey, subNode in pairs(subNodeDict) do
		local funcType = subNode[2] or (subNode[3] and subNode[3][1])
		if FunctionType.isClass(funcType) then
			if subcmd then
				self.mSkynetType:addSubcmdFunction(subcmd, lastKey, funcType)
			else
				self.mSkynetType:addCmdFunction(lastKey, funcType)
			end
		else
			self.logger.print("error not a function !!!")
		end
	end
end

function SkynetEmbed:getSkynetType()
	return self.mSkynetType
end

function SkynetEmbed:toString()
	return self.mSkynetType:toString()
end

local ClassProtoType = require "luaDeco/decoType/ClassProtoType"
local ClassEmbed = class()
function ClassEmbed:ctor(fileContext, globalContext, logger)
	self.mClassProtoType = ClassProtoType.new()

	self.fileContext = fileContext
	self.globalContext = globalContext
	self.logger = logger
end

function ClassEmbed:setDefine(name, upvalue)
	local className = self.fileContext:getFileBody().."#"..name
	self.mClassProtoType:setClassName(className)

	local subNodeDict = upvalue:getTypeListDict()[1]
	for lastKey, subNode in pairs(subNodeDict) do
		local funcType = subNode[2] or (subNode[3] and subNode[3][1])
		if FunctionType.isClass(funcType) then
			self.mClassProtoType:addFunction(lastKey, funcType)
		else
			self.logger.print("class's sub not functionType")
		end
	end
end

function ClassEmbed:selfAdd(upvalue)
end

function ClassEmbed:getClassProto()
	return self.mClassProtoType
end


function ClassEmbed:toString()
	return self.mSkynetType:toString()
end


return {
	SkynetEmbed = SkynetEmbed
}
