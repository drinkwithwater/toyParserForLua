local seri = require "seri"
local class = require "util/oo"
local decorator = require "luaDeco/decorator"
local Decorator = require "luaDeco/decorator/Decorator"

local FileEnv = class()

function FileEnv:ctor()
	self.nameToDeco = {}					-- name to deco
	self.nameToRequireFile = {}				-- name to filebody
	self.retUpValue = nil
end

function FileEnv:createGlobal(requireFileEnvDict)
	local globalDict = {}
	for name, v in pairs(decorator) do
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
	local deco = nil
	if self.retType and self.retType.createDecorator then
		deco = self.retType:createDecorator()
	else
		deco = Decorator.new()
	end

	for k,v in pairs(self.nameToDeco) do
		deco[k] = v
	end
	return deco
end

-- setter & getter
function FileEnv:getRetUpValue()
	return self.retUpValue
end

function FileEnv:setRetUpValue(vUpValue)
	self.retUpValue = vUpValue
end

function FileEnv:getNameDeco(name)
	return self.nameToDeco[name]
end

function FileEnv:getDeclareEnv()
	return setmetatable({}, {
		__index=function(t,k)
			return decorator[k] or self.nameToDeco[k]
		end,
		__newindex=function(t,k,v)
			self.nameToDeco[k] = v
		end
	})
end

function FileEnv:setNameDeco(name, deco)
	self.nameToDeco[name] = deco
end

function FileEnv:addRequire(name, fileBody)
	self.nameToRequireFile[name] = fileBody
end

return FileEnv
