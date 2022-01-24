function util.GetEntitySides(entity)
	local min = entity:OBBMins()
	
	local pos, ang = entity:GetPos(), entity:GetAngles() 
	local sides = {
		top = pos + (ang:Forward() * min.x),
		bottom = pos + (ang:Forward() * -min.x),
		left = pos + (ang:Right() * -min.y),
		right = pos + (ang:Right() * min.y)
	}
		
	return sides
end

function util.RandomPosOnEntity(entity, spacing)
	local pos = entity:GetPos()
	
	local sides = util.GetEntitySides(entity)
	local top, bottom = sides.top, sides.bottom
	local left, right = sides.left, sides.right
	
	local newX = math.random(math.min(top.x + spacing, bottom.x - spacing), math.max(top.x + spacing, bottom.x - spacing))
	local newY = math.random(math.min(left.y + spacing, right.y - spacing), math.max(left.y + spacing, right.y - spacing))
	
	pos.x, pos.y = newX, newY
	
	return pos
end

if not SERVER then return end

function util.PushAllAway(ent, distance, vel)
	for _, v in pairs(ents.FindInSphere(ent:GetPos(), distance)) do
		if v == ent then continue end
		
		local pos = v:GetPos()
		local vec = ent:GetPos() - pos
		local force = math.abs((vel - ent:GetPos():Distance(pos)) * 0.125)
		
		v:SetVelocity(vec:GetNormalized() * -force)	
	end
end
