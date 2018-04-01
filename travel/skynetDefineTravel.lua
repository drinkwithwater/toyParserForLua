local cjson = require "cjson"
local NodeLogger = require "nodeLogger"
local embed = require "luaDeco/embed"
local AstNode = require "astNode"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("skynetDefine", fileContext:getFileBody())

	local uvTree = fileContext:getUVTree()

	-- get return $name
	local lastAstNode = fileContext:getLastAstNode()
	local retName = nil
	if lastAstNode then
		retName = AstNode.checkReturnName(lastAstNode)
	end

	-- create service
	local service = embed.SkynetEmbed.new(fileContext, globalContext, logger)
	fileContext:setService(service)
	if retName then
		local upValue = uvTree:search(retName)
		service(upValue)
	end

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
			["function"]=function(node)
				-- parse for soa case:

				-- check $CMD.$init
				if not retName then
					return
				end
				local nameList = node.var_function.name_dot_list
				if #nameList ~= 2 then
					return
				end
				if nameList[1].name ~= retName then
					return
				end
				if nameList[2].name ~= "init" then
					return
				end

				-- check CMD.init($name)
				local name_list = node.argv.name_list
				if not name_list then
					logger.warning(node.name_list, "soa service use wrong format...")
					return
				end
				if #name_list < 1 then
					logger.warning(node.name_list, "soa service use wrong format...")
					return
				end

				local bootstrapName = name_list[1].name
				-- check args
				for k, stmt in ipairs(node.block) do
					local args = AstNode.checkCall(stmt, bootstrapName, "register")
					if args.__subtype == "(expr_list)" then
						local expr_list = args.expr_list
						if #expr_list== 2 then
							local str = AstNode.checkExprString(expr_list[1])
							local name = AstNode.checkExprName(expr_list[2])
							local upValue = uvTree:search(name)
							service(str, upValue)
						else
							logger.warning(stmt, "soa service use wrong format...")
						end
					else
						logger.warning(stmt, "soa service use wrong format...")
					end
				end
			end,

		},

	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())

end
