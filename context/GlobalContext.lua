local UVTree = require "uvTree"
local class = require "util/oo"
local FileDecoEnv = require "luaDeco/fileEnv"

local GlobalContext = class()
function GlobalContext:ctor()
	self.globalValue = UVTree.createGlobalValue()
	self.fileContextDict = {}
	self.fileDecoEnvDict = {}
	self.serviceDict = {}
end

function GlobalContext:getGlobalValue()
	return self.globalValue
end

function GlobalContext:getFileDecoEnvDict()
	return self.fileDecoEnvDict
end

function GlobalContext:getFileContext(fileBody)
	return self.fileContextDict[fileBody]
end

function GlobalContext:setFileContext(fileBody, fileContext)
	self.fileContextDict[fileBody] = fileContext
	if type(fileContext) == "table" then
		self.fileDecoEnvDict[fileBody] = fileContext:getFileDecoEnv()
	end
end

function GlobalContext:getService(fileBody)
	return self.serviceDict[fileBody]
end

function GlobalContext:setService(fileBody, service)
	self.serviceDict[fileBody] = service
end

return GlobalContext
