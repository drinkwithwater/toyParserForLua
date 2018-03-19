if not arg[1] then
	print("usage: lua uvCheck.lua xxx.lua")
	return
else
	local parser = require "parser"
	local travelList = {
		require  "travel/posTravel",
		require  "travel/uvTravel"
	}
	parser.parse(arg[1], nil, travelList)

end
