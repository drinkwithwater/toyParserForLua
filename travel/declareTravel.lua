local cjson = require "cjson"
local NodeLogger = require "nodeLogger"

return function(fileContext, globalContext)
	local travel = nil
	local rawtravel = nil
	local logger = NodeLogger.new("declare", fileContext:getFileBody())
	local fileEnv = fileContext:getFileDecoEnv()

	local function checkNodeDeco(node)
		local buffer = node.buffer
		if not buffer then
			return false
		elseif buffer:sub(1,5) == "--[[@" then
			return buffer
		else
			return false
		end
	end

	local function getFileBodyFromExpr(expr)
		if expr.__subtype~="prefix_exp" then
			return nil
		elseif expr.prefix_exp.__subtype~="function_call" then
			return nil
		end

		-- check has require
		local fileBody = expr.prefix_exp.__require
		if not fileBody then
			return nil
		else
			local subFileContext = globalContext:getFileContext(fileBody)
			if subFileContext then
				return fileBody
			end
		end
		return nil
	end

	local travelDict={
		stmt={
			["deco_declare"]=function(node)
				local buffer = checkNodeDeco(node)
				if not buffer then
					return
				end
				-- parse from buf
				local first = buffer:find("@") + 1
				local last = #buffer - 2
				local content = buffer:sub(first, last)
				-- load
				local block = load(content, "declare", "t", fileEnv:getDeclareEnv())
				local ok, result = pcall(block)
				if not ok then
					logger.error(node, "declare failed...", result)
				end
			end,
			["assign"]=function(node)
				if #node.var_list~=1 or #node.expr_list~=1 then
					rawtravel(node)
					return
				end

				-- check var
				local var=node.var_list[1]
				if var.__subtype~="name" then
					rawtravel(node)
					return
				end

				-- check expr
				local requireFile = getFileBodyFromExpr(node.expr_list[1])
				if not requireFile then
					rawtravel(node)
					return
				end

				fileContext:getFileDecoEnv():addRequire(var.name.name, requireFile)
			end,
			["local"]=function(node)
				if not node.name_list or not node.expr_list then
					rawtravel(node)
					return
				end

				if #node.name_list~=1 or #node.expr_list~=1 then
					rawtravel(node)
					return
				end

				-- check name
				local nameNode=node.name_list[1]

				-- check expr
				local requireFileBody = getFileBodyFromExpr(node.expr_list[1])
				if not requireFileBody then
					rawtravel(node)
					return
				end

				fileContext:getFileDecoEnv():addRequire(nameNode.name, requireFileBody)
			end,
		}
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)
	travel(fileContext:getAST())
end
