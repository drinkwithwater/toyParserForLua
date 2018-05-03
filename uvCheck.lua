require "functions"
GLOBAL = {
	sg = true,
	EM = true,
	SG_EM = true,
}
for k,v in pairs(_G) do
	GLOBAL[k] = true
end
if not arg[1] then
	print("usage: lua uvCheck.lua xxx.lua")
	return
else
	local parser = require "parser"
	local travelList = {
		require  "travel/posTravel",
		require  "travel/uvTravel",
	}
	parser.parse(arg[1], nil, travelList, true)

end
