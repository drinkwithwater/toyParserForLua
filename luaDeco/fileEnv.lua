local class = require "util/oo"
local baseClass = require "luaDeco/baseClass"

local function RenameDeco(fileEnv)
	local obj = setmetatable({},{
		__index=function(t,name)
			return fileEnv:getNameDeco(name)
		end
	})
	function obj:decorator(...)
		return fileEnv:getRetDeco():decorator(...)
	end
	return obj
end

local FileEnv = class()

function FileEnv:ctor()
	self.nameToDeco = {}
	self.nameToRequireFile = {}
	self.retDeco = nil
end

function FileEnv:createGlobal(requireFileEnvDict)
	local globalDict = {}
	for name, v in pairs(baseClass) do
		globalDict[name] = v
	end

	for name, v in pairs(self.nameToDeco) do
		globalDict[name] = v
	end

	for name, fileBody in pairs(self.nameToRequireFile) do
		local requireFileEnv = requireFileEnvDict[fileBody]
		globalDict[name] = requireFileEnv:createForName()
	end
	return globalDict
end

function FileEnv:createForName()
	return RenameDeco(self)
end

-- setter & getter
function FileEnv:getRetDeco()
	return self.retDeco
end

function FileEnv:setRetDeco(deco)
	self.retDeco = deco
end

function FileEnv:getNameDeco(name)
	return self.nameToDeco[name]
end

function FileEnv:setNameDeco(name, deco)
	self.nameToDeco[name] = deco
end

function FileEnv:addRequire(name, fileBody)
	self.nameToRequireFile[name] = fileBody
end

return FileEnv
