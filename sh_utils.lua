function util.GetEntitySides(entity)
	local min = entity:OBBMins()
	
	local pos, ang = entity:GetPos(), entity:GetAngles() 
	local sides = {
		top = pos + (ang:Forward() * min.x),
		bottom = pos + (ang:Forward() * -min.x,
		left = pos + (ang:Right() * -min.y),
		right = pos + (ang:Right() * min.y)
	}
		
	return sides
end

function util.RandomPosOnEntity(entity, spacing)
	local pos = entity:GetPos()
	
	local parts = util.GetEntitySides(entity)
	local top, bottom = parts.top, parts.bottom
	local left, right = parts.left, parts.right
	
	local newX = math.random(math.min(top.x + spacing, bottom.x - spacing), math.max(top.x + spacing, bottom.x - spacing))
	local newY = math.random(math.min(left.y + spacing, right.y - spacing), math.max(left.y + spacing, right.y - spacing))
	
	pos.x, pos.y = newX, newY
	
	return pos
end
