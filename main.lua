NATIVE_ENV = {}

ROOT_PATH = ""

REQUIRE_PATH_LIST = {
	"" --"/home/cz/workspace/toyParserForLua/test/"
}

SERVICE_PATH_LIST = {
	"" --"/home/cz/workspace/toyParserForLua/test/"
}

CLIB_PATH_LIST = {
}

if not arg[1] then
	print("usage: lua main.lua xxx.lua")
	return
else
	local context = require "context"
	local globalContext = context.GlobalContext.new()

	local parser = require "parser"
	parser.parse(arg[1], globalContext)

	local globalValue = globalContext:getGlobalValue()
	print("_G="..globalValue:getDictString(0))
end
