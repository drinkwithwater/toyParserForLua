local UVTree = require "uvTree"
local class = require "util/oo"

local FileContext = class()

function FileContext:ctor(ast)
	self.uvTree = nil
	self.ast = ast
	self.declareDict = {}
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

local GlobalContext = class()
function GlobalContext:ctor()
	self.globalValue = UVTree.createGlobalValue()
	self.fileContextDict = {}
end

function GlobalContext:getGlobalValue()
	return self.globalValue
end

function GlobalContext:getFileContext(fileBody)
	return self.fileContextDict[fileBody]
end

function GlobalContext:setFileContext(fileBody, context)
	self.fileContextDict[fileBody] = context
end

return {
	GlobalContext = GlobalContext,
	FileContext = FileContext
}
