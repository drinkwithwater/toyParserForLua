
if not arg[1] then
	print("usage: lua main.lua xxx.lua")
	return
else
	local parser = require "parser"
	parser.parse(arg[1])
end
