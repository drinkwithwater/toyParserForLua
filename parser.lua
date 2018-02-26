local cjson = require "cjson"
local parser = require "decoParser"
local travel = require "travel"
local seri = require "seri"
local astSeri = require "astSeri"

local mem = {}

if not arg[1] then
	print("usage: lua parser.lua xxx")
	return
end

local fileOpen = io.open(arg[1])
local script = fileOpen:read("a")
fileOpen:close()
parser.parse(script, mem)

local nodeTable = mem
local root = nodeTable[mem[#mem]]

--print("root:",root)
--print(cjson.encode(nodeTable))
local ast = {}

local function copyRef(astNode, node)
	for k,v in pairs(node) do
		if k=="__subtype" or k=="__type"  or k=="__col" or k=="__row" then
			astNode[k] = v
		else
			if type(v) == "number" then
				local subNode = nodeTable[v]
				if type(subNode) == "string" then
					astNode[k] = subNode
				elseif type(subNode) == "table" then
					astNode[k] = {}
					copyRef(astNode[k], subNode)
				end
			else
				print("ast exception")
			end
		end
	end
end

copyRef(ast, root)

local posTravel = require  "travel/posTravel"
posTravel(ast)

local uvTravel = require  "travel/uvTravel"
local uvTree = uvTravel(ast)

local decoTravel = require  "travel/decoTravel"
decoTravel(ast, uvTree)

uvTree.firstTable:show(1)
print(astSeri(ast))
--print(seri(ast))
