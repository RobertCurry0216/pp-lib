function table.each( t, fn )
	if not fn then return end

	for _, e in pairs(t) do
		fn(e)
	end
end

function math.sign(n)
	if n > 0 then
		return 1
	elseif n < 0 then
		return -1
	end

	return 0
end