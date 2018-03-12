local UVTree = require "uvTree"
local class = require "util/oo"
local FileDecoEnv = require "luaDeco/fileEnv"

local FileContext = class()

function FileContext:ctor(ast, fileBody)
	self.uvTree = nil
	self.ast = ast
	self.declareDict = {}
	self.fileDecoEnv = FileDecoEnv.new()
	self.fileBody = fileBody
end

function FileContext:getFileBody()
	return self.fileBody
end

function FileContext:getUVTree()
	return self.uvTree
end

function FileContext:setUVTree(uvTree)
	self.uvTree = uvTree
end

function FileContext:getAST()
	return self.ast
end

function FileContext:setDeclare(name, declare)
	self.declareDict[name] = declare
end

function FileContext:getDeclare(name)
	return self.declareDict[name]
end

function FileContext:getDeclareDict()
	return self.declareDict
end

function FileContext:getLastAstNode()
	return self.ast[#self.ast]
end

function FileContext:getFileDecoEnv()
	return self.fileDecoEnv
end

local GlobalContext = class()
function GlobalContext:ctor()
	self.globalValue = UVTree.createGlobalValue()
	self.fileContextDict = {}
	self.fileDecoEnvDict = {}
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
	self.fileDecoEnvDict[fileBody] = fileContext:getFileDecoEnv()
end

return {
	GlobalContext = GlobalContext,
	FileContext = FileContext
}
