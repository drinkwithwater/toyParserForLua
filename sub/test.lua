local sub = require "sub"

local cjson = require "cjson"

local decorator={}

local NodeCheck={}

function NodeCheck:simpleCheck(vType)
	if self.__type == "type" then
		return self.type == vType
	else
		print("type error when check function", cjson.encode(self))
		return false
	end
end

function decorator:init()
	self.interfaceDict={}
	self.classDict={}
end

function decorator:parseScript(row, script)
	local mem = {}
	-- parse, save result in mem
	sub.parse(row, script, mem)
	local root = mem[mem[#mem]]

	local function copyRef(astNode, srcNode)
		for k,v in pairs(srcNode) do
			if type(v) == "number" then
				local subNode = mem[v]
				if type(subNode) == "table" then
					astNode[k] = {}
					copyRef(astNode[k], subNode)
				else
					astNode[k] = subNode
				end
			else
				astNode[k] = v
			end
		end
	end
	local ast={}
	copyRef(ast, root)

	-- return decorator
	if ast.__type then
		return ast
	else
		-- save declare list
		for k,v in pairs(ast) do
			if v.__type=="declare" then
				-- TODO expand for package
				self.interfaceDict[v.name] = v
				print("add interface : ", v.name)
			else
				error("unexception if branch", cjson.encode(v))
			end
		end
	end
end

function decorator:show()
	print("interface:")
	for k,v in pairs(self.interfaceDict) do
		print("",k, cjson.encode(v))
	end
end




local script=[[
interface dosth {vcx=Number}
]]

local script2=[[

interface dosth2 {
	data1=Number,
	data2=Number
}
]]

local script3=[[
	(Number) . (Number) -<
]]

decorator:init()
decorator:parseScript(1, script)
decorator:parseScript(10, script2)
local deco_type = decorator:parseScript(15, script3)
print(cjson.encode(deco_type))
print(NodeCheck.simpleCheck(deco_type, "Number"))
-- decorator:show()
