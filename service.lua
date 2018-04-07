NATIVE_ENV = require "bootstrap/skynetEnv"

ROOT_PATH = "../../server/"

REQUIRE_PATH_LIST = {
	"skynet/lualib/compat10/",
	"skynet/lualib/",

	"SGSkynet/sg_server/src/",

	"wom/src/",

	"gateCluster/src/",

	"common/lua/",
}

SERVICE_PATH_LIST = {
	"skynet/service/",

	"SGSkynet/sg_server/service/",

	"wom/service/",

	"gateCluster/service/",
}

CLIB_PATH_LIST = {
	"skynet/luaclib/",

	"common/luaclib/linux/",
}

if not arg[1] then
	print("usage: lua main.lua xxx.lua")
	return
else
	local GlobalContext = require "context/GlobalContext"
	local globalContext = GlobalContext.new()

	local parser = require "parser"
	parser.parse(arg[1], globalContext, {
		require "travel/posTravel",
		require "travel/uvTravel",
		require "travel/declareTravel",
		require "travel/decoTravel",
		require "travel/deduceTravel",
		require "travel/skynetDefineTravel",
	})

	local globalValue = globalContext:getGlobalValue()
	print("_G="..globalValue:getDictString(0))
end
