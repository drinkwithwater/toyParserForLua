local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local embed = require "luaDeco/embed"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("skynet", fileContext:getFileBody())

	local uvTree = fileContext:getUVTree()

	local function checkNodeEmbed(node)
		local buffer = node.buffer
		if not buffer then
			return false
		elseif buffer:sub(1,5) == "--[[$" then
			return buffer
		elseif buffer:sub(1,3) == "--$" then
			return buffer
		else
			return false
		end
	end

	local envMeta={
		__index=function(t, k)
			local upValue = uvTree:search(k)
			return upValue
		end,
	}

	local travelDict={
		stmt={
			["deco_declare"]=function(node)
				local buffer = checkNodeEmbed(node)
				if not buffer then
					return
				end
				local service = embed.SkynetEmbed.new()
				fileContext:setService(service)

				local embedEnv = setmetatable({
					Skynet = service
				}, envMeta)

				-- parse from buf

				local first = buffer:find("[$]") + 1
				local last = #buffer - 2
				local content = buffer:sub(first, last)
				-- load
				local block = load(content, "embed", "t", embedEnv)
				local ok, result = pcall(block)
				if not ok then
					logger.error(node, "embed failed...", result)
				end
			end,
			["local"]=function(node)
				-- TODO
			end,

		},

	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())

end
