BTTVEmotes = {
	Channels = {
		['im_dontai'] = { // twitch channel name
			// ['*'] = true, will make it download all from bttv channel emotes
			['catJAM'] = true, // bttv emote code
		}
	},

	// DO NOT TOUCH
	emote_image = {}, // tbl for def emotes
	emote_gif = {}, // tbl for gif emotes
	framerate_cache = {}, // tbl for gif framerates

	check = function(channel, name) // check if we need to download all or not
		if BTTVEmotes.Channels[channel]['*'] then
			return true
		end 
		return BTTVEmotes.Channels[channel][name]
	end,

	URL = 'https://cdn.betterttv.net/emote/%s/3x', // url to bttv 
	GIFINFO = 'http://sprays.xerasin.com/gifinfo.php?url=%s', // url to get gif framerate
	TOVTF = 'http://sprays.xerasin.com/getimage2.php?url=%s&type=vtf' // url to convert gif to vtf
}



local function InitEmotes()
	for channel, emote in pairs(BTTVEmotes.Channels) do
		http.Fetch('https://api.betterttv.net/2/channels/' .. channel, function(body)
			local tbl = util.JSONToTable(body) // convert result to json
			if not tbl then return end // check if channel is not valid

			for _, v in pairs(tbl.emotes) do // get all emotes from tbl
				local name = v.code:Replace(':', '_')
				if BTTVEmotes.check(channel, name) then // checking if we need to download emote
					if v.imageType == 'gif' then // type cheeeeeck
						BTTVEmotes.emote_gif[name] = v.id // throwing gif to cache
						local gifurl = BTTVEmotes.URL:format(BTTVEmotes.emote_gif[name]) // receive bttv url to emote
						http.Fetch(BTTVEmotes.GIFINFO:format(gifurl), function(data, _, _, code) // receive emote gif info
							if code ~= 200 then return end

							BTTVEmotes.framerate_cache[name] = tonumber(data) // throwing gif framerate to cache
						end)

						http.Fetch(BTTVEmotes.TOVTF:format(gifurl), function(data) // download emote gif to player data
							file.Write('bttv/emotes/' .. name .. '.vtf', data)
						end)
					else
						BTTVEmotes.emote_image[name] = v.id // throwing emote to cache
						http.Fetch(BTTVEmotes.URL:format(BTTVEmotes.emote_image[name]), function(data)
							file.Write('bttv/emotes/' .. name .. '.png', data) // download emote to player data
						end)
					end
				end
			end
		end)
	end
end

InitEmotes()

local function gif_material(name, path) 
	return CreateMaterial("bttvemotes_" .. name, "UnlitGeneric", {
		["$basetexture"] = "../data/" .. path,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$transparent"] = 1,
		["Proxies"] = {
			AnimatedTexture = {
				animatedtexturevar = "$basetexture",
				animatedtextureframenumvar = "$frame",
				animatedtextureframerate = BTTVEmotes.framerate_cache[name] or 8,
			}
		},
	})
end

function BTTVEmotes.GetEmote(emote) 
	if BTTVEmotes.emote_gif[emote] then
		local path = 'bttv/emotes/'.. emote ..'.vtf'
		local exists = file.Exists(path, 'DATA')

		if exists then
			local mat = gif_material(emote, path)
			if mat and not mat:IsError() then
				return mat	
			end
		end
	else
		local path = 'bttv/emotes/'.. emote ..'.png'
		local exists = file.Exists(path, 'DATA')

		if exists then
			local mat = Material('data/' .. path)
			if mat and not mat:IsError() then
				return mat	
			end
		end		
	end
end

concommand.Add('bttv_emotestest', function()

	local pnl = vgui.Create('DFrame')
	pnl:SetSize(ScrW(), ScrH())
	pnl:Center()
	pnl:MakePopup()
	pnl:SetTitle('Emotes Test')

	local scroll = vgui.Create('DScrollPanel', pnl)
	scroll:Dock(FILL)

	local layout = vgui.Create('DIconLayout', scroll)
	layout:Dock(FILL)

	for name, _ in pairs(BTTVEmotes.emote_image) do
		local mat = BTTVEmotes.GetEmote(name)
		local emote = layout:Add('EditablePanel')
		emote:SetSize(128, 128)
		emote.Paint = function(self, w, h)
			surface.SetMaterial(mat)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end

end)