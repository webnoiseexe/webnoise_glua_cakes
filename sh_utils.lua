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

function util.InFOV(ent1, ent2, fov, ang) -- that from Garry's Mod discord server (https://discord.com/channels/565105920414318602/567617926991970306/975335373842554891)
	local sp, ep = ent1:GetPos(), ent2:GetPos()

	local ang = (sp - ep):Angle() - ang
	ang:Normalize()
	return math.abs(ang.yaw) < fov and math.abs(ang.pitch) < fov
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
