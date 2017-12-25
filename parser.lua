local cjson = require "cjson"
local parser = require "decoParser"
local travel = require "travel"

parser.parse()

local nodeTable = parser.get()
local root = nodeTable[parser.getRoot()]

print("root:",root)
print(cjson.encode(nodeTable))
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

local function showDepth(node, depth)
	local myPrint=function(str)
		print(string.rep("  ",depth)..str)
	end
	if node.__type then
		if node.__subtype then
			myPrint(node.__type.."|"..node.__subtype.." {")
		else
			myPrint(node.__type.." {")
		end
		for k,v in pairs(node) do
			if k~="__type" and k~="__subtype" and k~="row" and k~="col" then
				if type(v) == "table" then
					myPrint("  "..k)
					showDepth(v, depth+2)
				else
					myPrint("  "..k..":"..v)
				end
			end
		end
		myPrint("}")
	elseif node[1] then
		for k,v in pairs(node) do
			if type(v) == "table" then
				showDepth(v, depth+1)
			else
				myPrint(v)
			end
		end
	else
		for k,v in pairs(node) do
			if k~="__type" and k~="__subtype" and k~="row" and k~="col" then
				if type(v) == "table" then
					myPrint(k)
					showDepth(v, depth+1)
				else
					myPrint(k..":"..v)
				end
			end
		end
	end
end

showDepth(ast, 0)
local idList = travel(ast)
print(cjson.encode(idList))
