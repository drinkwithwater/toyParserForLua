local cjson = require "cjson"
local decoParser = require "decoParser"
local seri = require "seri"
local astSeri = require "astSeri"
local NodeLogger = require "nodeLogger"

local log = require "log"
local context = require "context"

local function parse(fileName, globalContext)

	local fileOpen = io.open(fileName, "r")
	if not fileOpen then
		log.error(fileName.." not found")
		return nil
	else
		log.info("----- parsing "..fileName.." -----")
	end
	local mem = {}
	local script = fileOpen:read("a")
	fileOpen:close()
	decoParser.parse(script, mem)

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
					log.error("ast exception")
				end
			end
		end
	end

	copyRef(ast, root)

	local globalContext = globalContext or context.GlobalContext.new()
	local fileContext = context.FileContext.new(ast)

	local posTravel = require  "travel/posTravel"
	posTravel(fileContext, globalContext)

	local staticRequireTravel = require  "travel/staticRequireTravel"
	staticRequireTravel(fileContext, globalContext)

	local uvTravel = require  "travel/uvTravel"
	uvTravel(fileContext, globalContext)

	local decoTravel = require  "travel/decoTravel"
	decoTravel(fileContext, globalContext)

	fileContext:getUVTree().firstTable:show(1)
	log.info(astSeri(ast))
	return fileContext
end

return {
	parse = parse
}
