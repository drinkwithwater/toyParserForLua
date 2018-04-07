local class = require "util/oo"
local env = require "luaDeco/decoType/env"
local DecoType = require "luaDeco/decoType/DecoType"
local TypeTree = require "luaDeco/decoType/TypeTree"

local SkynetType = class(DecoType)

function SkynetType:ctor()
	self.mTree = TypeTree.new()
end

function SkynetType:addCmdFunction(vName, vFunction)
	self.mTree:add({vName}, vFunction)
end

function SkynetType:addSubcmdFunction(vSubcmd, vName, vFunction)
	self.mTree:add({vSubcmd, vName}, vFunction)
end

function SkynetType:toString()
	-- return "Type[Skynet]\n"..table.concat(self.mTree:toString({}), "\n")
	return self.mTree:toString()
end

env.SkynetType = SkynetType
return SkynetType
