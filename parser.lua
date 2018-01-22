local cjson = require "cjson"
local parser = require "decoParser"
local travel = require "travel"
local subParser = require "sub/subParser"

local mem = {}
fileOpen = io.open("skynet.lua")
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
		if k=="__subtype" or k=="__type"  or k=="col" or k=="row" then
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

travel(ast)

--idMeta  = require "idMeta"
--idMeta:show()

