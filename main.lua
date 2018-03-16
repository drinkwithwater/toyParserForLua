REQUIRE_PATH= "" --"/home/cz/workspace/toyParserForLua/test/"
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
