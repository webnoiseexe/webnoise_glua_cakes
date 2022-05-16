local POINTUSE = {}
POINTUSE.Zones = {
    {
        text = {
            [1] = {
                text = 'Press [E] to action', 
                font = 'PU.24', 
                color = color_white
            },
        },
        min = Vector(-890, -159, 350),
        max = Vector(-900, -210, 461),
--         nodraw = function()
--             return true
--         end,
        start = function() 
            
        end
    }
}

local function centerBox(min, max)
    return Vector( (min.x + max.x) / 2, (min.y + max.y)/2, (min.z + max.z)/2 )
end

surface.CreateFont('PU.24', { font = 'Arial', size = 24, weight = 300, extended = true })
local function drawText(text, font, color, x, y)
    draw.SimpleText(text, font, x, y + 1, ColorAlpha(color_black, color.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end 

hook.Add('HUDPaint', 'PointUse.DrawText', function()
    for k, v in pairs(POINTUSE.Zones) do
        if v.nodraw then
            if v.nodraw() == true then continue end
        end

        if v.text then
            local center = centerBox(v.min, v.max)

            if not LocalPlayer():IsLineOfSightClear(center) then continue end

            local dist = LocalPlayer():GetPos():DistToSqr(center)
            alpha = (122500 - dist) / 350

            center = center:ToScreen()
            
            local c_t, c_f, c_c = '', 'PU.24', color_white
            for k, arg in pairs(v.text) do
                if arg.text then c_t = arg.text end
                if arg.font then c_f = arg.font end
                if arg.color then c_c = arg.color end

                drawText(c_t, c_f, ColorAlpha(c_c, alpha), center.x, center.y + (k * draw.GetFontHeight(c_f)))
            end
        end
    end
end)

-- hook.Add( "PostDrawTranslucentRenderables", "PointUse.Draw", function()
--     for k, v in pairs(POINTUSE.Zones) do
--         render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), v.min, v.max, color_white, true)

--         -- local eyes = LocalPlayer():EyePos()
--         -- local startpos, endpos = eyes, LocalPlayer():EyePos() + EyeAngles():Forward() * 10000
--         -- local trace = util.TraceLine({
--         --     start = startpos,
--         --     endpos = endpos
--         -- })
--         -- render.DrawLine( startpos, endpos, color_red )
--     end
-- end)

local nextuse = 0
hook.Add('KeyRelease', 'PointUse.Trigger', function(player, key)
    if player == LocalPlayer() then
        if key == IN_USE and nextuse < CurTime() then
            local trace = LocalPlayer():GetEyeTrace().HitPos + LocalPlayer():GetAngles():Forward() * 2
            for k, v in pairs(POINTUSE.Zones) do
                local center = centerBox(v.min, v.max)
                if player:GetPos():Distance(center) > 80 then continue end

                if trace:WithinAABox(v.min, v.max) then
                    if v.start then v.start(player) end
                    nextuse = CurTime() + 1
                end
            end
        end
    end
end)

