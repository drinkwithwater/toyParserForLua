local cjson = require "cjson"
local decoParser = require "decoParser"
local seri = require "seri"
local astSeri = require "astSeri"
local NodeLogger = require "nodeLogger"

local log = require "log"
local FileContext = require "context/FileContext"
local GlobalContext= require "context/GlobalContext"

local posTravel = require  "travel/posTravel"

local staticRequireTravel = require  "travel/staticRequireTravel"
local skynetIncludeTravel = require "travel/skynetIncludeTravel"

local uvTravel = require  "travel/uvTravel"
local declareTravel = require  "travel/declareTravel"
local decoTravel = require  "travel/decoTravel"
local deduceTravel = require  "travel/deduceTravel"

local classDefineTravel = require "travel/classDefineTravel"
local skynetDefineTravel = require "travel/skynetDefineTravel"

local function parseSomeTravel(fileBody, fileOpen, globalContext, travelList)
	log.info("----- start parsing "..fileBody..".lua {{{")
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

	local globalContext = globalContext or GlobalContext.new()
	local fileContext = FileContext.new(ast, fileBody)

	for k,aTravel in pairs(travelList) do
		aTravel(fileContext, globalContext)
	end

	log.info("}}} finish parsing "..fileBody..".lua -----")
	return fileContext
end

local function parseMain(fileName, globalContext, travelList)
	local fileBody = fileName
	if fileName:sub(#fileName-3,#fileName) == ".lua" then
		fileBody = fileName:sub(1, #fileName-4)
	end

	local fileOpen, result = io.open(fileName)
	if not fileOpen then
		error("file open failed!!!, "..result)
	end

	local travelList = travelList or {
		posTravel,
		staticRequireTravel,
		uvTravel,
		skynetIncludeTravel,
		declareTravel,
		decoTravel,
		deduceTravel,
		classDefineTravel,
		skynetDefineTravel,
	}
	local fileContext = parseSomeTravel(fileBody, fileOpen, globalContext, travelList)

	fileContext:getUVTree():show()
	log.info(astSeri(fileContext:getAST()))
	log.info(astSeri(fileContext:getFileDecoEnv()))
	local service = fileContext:getService()
	if service then
		log.info("Skynet:", service:toString())
	end
end

local function parseStaticRequire(fileBody, globalContext)
	if NATIVE_ENV[fileBody] then
		globalContext:setFileContext(fileBody, true)
		return nil
	end
	local fileOpen = nil
	for k, path in pairs(REQUIRE_PATH_LIST) do
		local fileName = ROOT_PATH..path..fileBody..".lua"
		fileOpen = io.open(fileName)
		if fileOpen then
			break
		end
	end

	if not fileOpen then
		for k, path in pairs(CLIB_PATH_LIST) do
			local fileName = ROOT_PATH..path..fileBody..".so"
			fileOpen = io.open(fileName)
			if fileOpen then
				return nil
			end
		end
		error("require failed!!!! "..fileBody..".* not found")
	end
	local fileContext = parseSomeTravel(fileBody, fileOpen, globalContext, {
		posTravel,
		staticRequireTravel,
		skynetIncludeTravel,
		uvTravel,
		declareTravel,
		decoTravel,
		deduceTravel,
		classDefineTravel,
	})

	return fileContext
end

local function parseSkynetInclude(fileBody, globalContext, isSoa)
	local fileOpen = nil
	local usePathList = nil
	if isSoa then
		usePathList = REQUIRE_PATH_LIST
	else
		usePathList = SERVICE_PATH_LIST
	end

	for k, path in pairs(usePathList) do
		local fileName = ROOT_PATH..path..fileBody..".lua"
		fileOpen = io.open(fileName)
		if fileOpen then
			break
		end
	end
	if not fileOpen then
		error("service include failed!!!! "..fileBody..".lua not found")
	end
	local fileContext = parseSomeTravel(fileBody, fileOpen, globalContext, {
		posTravel,
		-- staticRequireTravel,
		uvTravel,
		declareTravel,
		decoTravel,
		deduceTravel,
		skynetDefineTravel,
	})
	local service = fileContext:getService()
	if service then
		log.info("Skynet:", service:toString())
	end
	return fileContext
end

return {
	parse = parseMain,
	parseSomeTravel = parseSomeTravel,
	parseStaticRequire = parseStaticRequire,
	parseSkynetInclude = parseSkynetInclude,
}
