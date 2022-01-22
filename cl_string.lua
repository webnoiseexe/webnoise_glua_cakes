function string.Wrap(text, font, width)
	local temp = {}
	local lastx = 0
	local lasty = 0
	local wide = 0
	
	local cur = ''
	
	for i, v in ipairs(string.ToTable(text)) do
		surface.SetFont(font)
		local w = surface.GetTextSize(v)
		if wide + w > width then
			temp[#temp + 1] = cur
			cur = ''
			wide = 0
		end
		cur = cur .. v
		wide = wide + w
	end
	
	if cur ~= '' then
		temp[#temp + 1] = cur
	end
	
	return temp
end