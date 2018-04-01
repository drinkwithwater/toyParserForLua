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
	self.service = nil
end

function FileContext:getService()
	return self.service
end

function FileContext:setService(service)
	self.service = service
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

return FileContext
