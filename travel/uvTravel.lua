local cjson = require "cjson"
local UVTree = require "uvTree"
local NodeLogger = require "nodeLogger"
local AstNode = require "astNode"

return function(fileContext, globalContext)
	local uvTree = UVTree.new(globalContext:getGlobalValue())
	local log = NodeLogger.new("uvTravel")

	local travel = nil
	local rawtravel = nil
	local travelCheckType = function(node, vType)
		if not vType == node.__type then
			log.error(node, "type check error")
		else
			return travel(node)
		end
	end
	local travelCheckTypeSubType = function(node, vType, vSubType)
		if (not vType == node.__type) or (not vSubType == node.__subtype) then
			log.error(node, "sub type check error")
		else
			return travel(node)
		end
	end

	local function setKeyList(node, preVar, newKey)
		if preVar.__index then
			node.__index = preVar.__index
			local key_list = {}
			for k,v in ipairs(preVar.__key_list or {}) do
				key_list[k] = v
			end
			key_list[#key_list + 1] = newKey
			node.__key_list = key_list
		else
			log.error(node, "unexcept if branch when setKeyList")
		end
	end

	local travelDict={
		stmt={
			["do"]=function(node)
				uvTree:getin(node)
				travel(node.block)
				uvTree:getout()
			end,
			["for"]=function(node)
				uvTree:getin(node)
				travelCheckType(node.head, "for_head")
				travelCheckType(node.block, "stmt_list")
				uvTree:getout()
			end,
			["while"]=function(node)
				uvTree:getin(node)
				travelCheckType(node.head, "expr_list")
				travelCheckType(node.block, "stmt_list")
				uvTree:getout()
			end,
			["local"]=function(node)
				if node.name_list then
					if node.expr_list then
						travel(node.expr_list)
					end
					for k, nameNode in ipairs(node.name_list) do
						nameNode.__index = uvTree:putid(nameNode)
					end
				elseif node.name then
					node.name.__index = uvTree:putid(node.name)

					uvTree:getin(node)
					travel(node.argv)
					travel(node.block)
					uvTree:getout()
				end
			end,
			["function"]=function(node)
				uvTree:getin(node)
				travel(node.var_function)
				if node.var_function.__subtype==":name" then
					local selfNode = {
						name="self",
						__type="name",
						__col=node.__col,
						__row=node.__row,
					}
					node.argv.self = selfNode
					selfNode.__index = uvTree:putid(selfNode)
				end
				travel(node.argv)
				travel(node.block)
				uvTree:getout()
			end,
			["if"]=function(node)

				travel(node.expr)
				uvTree:getin(node)
				travel(node.block)
				uvTree:getout()

				for k,elseif_item in ipairs(node.elseif_list) do
					travel(elseif_item.expr)
					uvTree:getin(elseif_item)
					travel(elseif_item.block)
					uvTree:getout()
				end

				if node.else_block then
					uvTree:getin(elseif_item)
					travel(node.else_block)
					uvTree:getout()
				end
			end,
			["assign"]=function(node)
				travel(node.expr_list)
				travel(node.var_list)
			end,
			["function_call"]=function(node)
				travel(node.prefix_exp)
				if node.name then
					if node.prefix_exp.__type=="var" and node.prefix_exp.__index then
						setKeyList(node, node.prefix_exp, node.name.name)
						local uvValue = uvTree:indexValue(node.__index)
						uvValue:addKeyList(node.__key_list)
					end
				end
				travel(node.args)
			end
		},
		function_lambda=function(node)
			uvTree:getin(node)
			travel(node.argv)
			travel(node.block)
			uvTree:getout()
		end,
		for_head={
			["in"]=function(node)
				travel(node.expr_list)
				for k, nameNode in ipairs(node.name_list) do
					nameNode.__index = uvTree:putid(nameNode)
				end
			end,
			["eqa"]=function(node)
				travel(node.expr_list)
				node.name.__index = uvTree:putid(node.name)
			end,
		},
		argv={
			["()"]=function(node)
			end,
			["(...)"]=function(node)
			end,
			["list"]=function(node)
				for k,nameNode in ipairs(node.name_list) do
					nameNode.__index = uvTree:putid(nameNode)
				end
			end,
			["list,..."]=function(node)
				for k,nameNode in ipairs(node.name_list) do
					nameNode.__index = uvTree:putid(nameNode)
				end
			end,
		},

		------------------------ parse id's tableValue ----------------
		var={
			["name"]=function(node)
				travel(node.name)
				local nameNode = node.name
				local uvValue = uvTree:search(nameNode.name)
				if uvValue then
					nameNode.__index = uvValue:getIndex()
					node.__index = uvValue:getIndex()
				else
					log.warning(node, nameNode.name.." undefined")
				end
			end,
			[".name"]=function(node)
				travel(node.prefix_exp)
				travel(node.name)
				if node.prefix_exp.__type=="var" and node.prefix_exp.__index then
					setKeyList(node, node.prefix_exp, node.name.name)
					local uvValue = uvTree:indexValue(node.__index)
					uvValue:addKeyList(node.__key_list)
				end
			end,
			["expr"]=function(node)
				travel(node.prefix_exp)
				travel(node.expr)
				if node.prefix_exp.__type=="var" and node.prefix_exp.__index and node.expr.__subtype=="value" then
					-- only parse expr for ["String"] or [Number]
					local valueNode = node.expr.value
					local value = nil
					if valueNode.__subtype=="number" then
						value = tonumber(valueNode.value)
					elseif valueNode.__subtype=="string" then
						value = valueNode.value
					else
						log.error(node, "use "..valueNode.__subtype.." as key...")
						return
					end
					-- only parse prefix_exp for var with __key_list
					setKeyList(node, node.prefix_exp, value)
					local uvValue = uvTree:indexValue(node.__index)
					uvValue:addKeyList(node.__key_list)
				end
			end,
		},
		var_function={
			["var"]=function(node)
				if #node.name_dot_list>0 then
					local firstName = node.name_dot_list[1].name
					local uvValue = uvTree:search(firstName)
					if uvValue then
						local key_list = {}
						for k,nameNode in ipairs(node.name_dot_list) do
							if k>1 then
								key_list[k-1] = nameNode.name
							end
						end
						node.__index = uvValue:getIndex()
						node.__key_list = key_list
						uvValue:addKeyList(node.__key_list)
					else
						log.warning(node, firstName.." undefined")
					end
				else
					log.error(node, "unexcept if branch when parse var")
				end
			end,
			[":name"]=function(node)
				if #node.name_dot_list>0 then
					local firstName = node.name_dot_list[1].name
					local uvValue = uvTree:search(firstName)
					if uvValue then
						local key_list = {}
						for k,nameNode in ipairs(node.name_dot_list) do
							if k>1 then
								key_list[k-1] = nameNode.name
							end
						end
						key_list[#key_list + 1] = node.name.name
						node.__index = uvValue:getIndex()
						node.__key_list = key_list
						uvValue:addKeyList(node.__key_list)
					else
						log.warning(node, firstName.." undefined")
					end
				else
					log.error(node, "unexcept if branch when parse var")
				end
			end
		},
	}

	local travelFactory = require "travel/travelFactory"
	travel, rawtravel = travelFactory.create(travelDict)

	travel(fileContext:getAST())
	fileContext:setUVTree(uvTree)
end
