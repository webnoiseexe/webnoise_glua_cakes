local sounds = {
	['heheheha'] = 'https://webnoise.space/resource/sounds/heheheha.mp3',
	['hentai'] = 'https://webnoise.space/resource/sounds/hentai.mp3',
}

local function parseText(text)
	local ex = string.Explode(' ', text)
	local temp = {}
	local current = ''
	
	for i = 1, #ex do
		local t = ex[i]

		if sounds[t] then
			current = string.Trim(current, ' ')
			table.insert(temp, current)
			current = ''
			
			table.insert(temp, t)
		else
			current = current .. t .. ' '
		end
		
		if i == #ex then
			if current ~= '' then
				current = string.Trim(current, ' ')
				table.insert(temp, current)	
			end
		end
		
	end
	
	return temp
end


local function soundPlayQueue(ply, queue)
	local current = 1
	if not queue[current] then return end
	
	local q_url = queue[current]
	
	local function play(ply, url)
	    sound.PlayURL(url, "3d", function(snd)
	        if IsValid(snd) and IsValid(ply) then
	            snd:SetPos(ply:GetPos())
	            snd:SetVolume(1)
	            snd:Play()
	            snd:Set3DFadeDistance(200, 1000)
	            ply.sound = snd
	            
	            local len = math.abs(snd:GetLength())
	            len = math.Round(len, 4)
	            if len <= 0 then
	            	len = 1	
	            end
	 

				timer.Simple(len, function()
					
					if (current + 1) <= #queue then
						current = current + 1
						play(ply, queue[current])
					end
				end)
	        end
	    end)	
	end
	
	play(ply, q_url)
end

local function httpUrlEncode(text) -- спасибо разрабам wiremod
    local ndata = string.gsub(text, "[^%w _~%.%-]", function(str)
        local nstr = string.format("%X", string.byte(str))
        return "%"..((string.len(nstr) == 1) and "0" or "")..nstr
    end)
    return string.gsub(ndata, " ", "+")
end

local function playParsedText(player, text)
	local queue = {}
	local c_queue = 0
	local parsed = parseText(text)
	
	for k, v in pairs(parsed) do
		if sounds[v] then
			queue[k] = sounds[v]	
		else
			local tts_url = 'http://tts.voicetech.yandex.net/tts?speaker=%s&text=%s'
			local voice = 'zahar'
			print(v)
			queue[k] = string.format(tts_url, string.lower(voice), httpUrlEncode(v))
		end
	end


	soundPlayQueue(player, queue)
end
	
local text = [[
	testmessage hentai test
]]

playParsedText(me, text)