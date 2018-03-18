local cjson = require "cjson"
local decoParser = require "decoParser"
local seri = require "seri"
local astSeri = require "astSeri"
local NodeLogger = require "nodeLogger"

local log = require "log"
local context = require "context"

local posTravel = require  "travel/posTravel"

local staticRequireTravel = require  "travel/staticRequireTravel"

local skynetIncludeTravel = require "travel/skynetIncludeTravel"

local uvTravel = require  "travel/uvTravel"

local declareTravel = require  "travel/declareTravel"

local decoTravel = require  "travel/decoTravel"

local deduceTravel = require  "travel/deduceTravel"

local function parseSomeTravel(fileName, globalContext, travelList)
	local fileOpen = io.open(fileName, "r")
	if not fileOpen then
		log.error(fileName.." not found")
		return nil
	else
		log.info("----- start parsing "..fileName.." {{{")
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
	local fileBody = fileName
	if fileName:sub(#fileName-3,#fileName) == ".lua" then
		fileBody = fileName:sub(1, #fileName-4)
	end
	local fileContext = context.FileContext.new(ast, fileBody)

	for k,aTravel in pairs(travelList) do
		aTravel(fileContext, globalContext)
	end

	log.info("}}} finish parsing "..fileName.." -----")
	return fileContext
end

local function parse(fileName, globalContext)

	local fileContext = parseSomeTravel(fileName, globalContext, {
		posTravel,
		staticRequireTravel,
		-- skynetIncludeTravel,
		uvTravel,
		declareTravel,
		decoTravel,
		deduceTravel,
	})

	fileContext:getUVTree():show()
	log.info(astSeri(fileContext:getAST()))
	log.info(astSeri(fileContext:getFileDecoEnv()))
	local service = fileContext:getService()
	if service then
		log.info("Skynet:", service:toString())
	end
end

local function parseStaticRequire(fileName, globalContext)
	local fileContext = parseSomeTravel(fileName, globalContext, {
		posTravel,
		staticRequireTravel,
		uvTravel,
		declareTravel,
		decoTravel,
		deduceTravel,
	})

	return fileContext
end

local function parseSkynetInclude(fileName, globalContext)
	local fileContext = parseSomeTravel(fileName, globalContext, {
		posTravel,
		staticRequireTravel,
		uvTravel,
		declareTravel,
		decoTravel,
		deduceTravel,
	})
	return fileContext
end

return {
	parse = parse,
	parseSomeTravel = parseSomeTravel
}
