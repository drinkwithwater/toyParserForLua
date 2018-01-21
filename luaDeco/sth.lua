require "oo"


local c1 = class()

function c1:dosth()
	print("c1:dosth")
end

function c1.__bor(a,b)
	print(a,b)
end

local c2 = class(c1)

--[[function c2:dosth()
	print("c2:dosth")
end]]


cc1 = c1.new()
cc2 = c2.new()

local sth = cc1|cc2

