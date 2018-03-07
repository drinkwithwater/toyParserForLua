function table.map(vT, func)
	local nT = {}
	for k,v in pairs(vT) do
		nT[k] = func(v, k)
	end
	return nT
end
