local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local embed = require "luaDeco/embed"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("skynet", fileContext:getFileBody())

	local uvTree = fileContext:getUVTree()

	local envMeta={
		__index=function(t, k)
			local upValue = uvTree:search(k)
			return upValue
		end,
	}

	local travelDict={
		stmt={
			["deco_embed"]=function(node)
				local service = embed.SkynetEmbed.new()
				fileContext:setService(service)

				local embedEnv = setmetatable({
					Skynet = service
				}, envMeta)

				-- parse from buf
				local first = node.buffer:find("[$]") + 1
				local last = #node.buffer - 2
				local content = node.buffer:sub(first, last)
				-- load
				local block = load(content, "embed", "t", embedEnv)
				local ok, result = pcall(block)
				if not ok then
					logger.error(node, "embed failed...", result)
				end
			end
		}
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())

end
