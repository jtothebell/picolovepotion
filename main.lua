pico8={
	fps=30,
	pal_transparent = {},
	resolution = {128,128},
	palette = {
		{0,0,0,255},
		{29,43,83,255},
		{126,37,83,255},
		{0,135,81,255},
		{171,82,54,255},
		{95,87,79,255},
		{194,195,199,255},
		{255,241,232,255},
		{255,0,77,255},
		{255,163,0,255},
		{255,240,36,255},
		{0,231,86,255},
		{41,173,255,255},
		{131,118,156,255},
		{255,119,168,255},
		{255,204,170,255}
	},
	camera_x = 0,
	camera_y = 0,
	audio_channels = {
		[0]={oscpos=0},
		[1]={oscpos=0},
		[2]={oscpos=0},
		[3]={oscpos=0}
	},
	sfx = {},
	music = {},
	current_music = nil,
	keypressed = {
		[0] = {},
		[1] = {}
	},
	keymap = {
		[0] = {
			[0] = {'left'},
			[1] = {'right'},
			[2] = {'up'},
			[3] = {'down'},
			[4] = {'z','n'},
			[5] = {'x','m'},
		},
		[1] = {
			[0] = {'s'},
			[1] = {'f'},
			[2] = {'e'},
			[3] = {'d'},
			[4] = {'tab','lshift'},
			[5] = {'q','a'},
		}
	},
	cursor = {0,0},
	camera_x = 0,
	camera_y = 0,
}

require("strict")
local bit = require("bit")
local QueueableSource = require "QueueableSource"

local flr,abs = math.floor, math.abs

local frametime = 1/pico8.fps
local cart = nil
local cartname = nil
local love_args = nil
local scale = 4
local xpadding = 8.5
local ypadding = 3.5
local __accum = 0
local __audio_buffer_size = 1024

local video_frames = nil
local osc
local host_time = 0
local retro_mode = false
local __audio_channels
local __sample_rate = 22050
local channels = 1
local bits = 16
local paused = false
local api, cart

log = print

local function get_bits(v,s,e)
	local mask = bit.lshift(bit.lshift(1,s)-1,e)
	return bit.rshift(bit.band(mask,v))
end

function restore_clip()
	if pico8.clip then
		love.graphics.setScissor(unpack(pico8.clip))
	else
		love.graphics.setScissor(0,0,pico8.resolution[1],pico8.resolution[2])
	end
end

local function _load(_cartname)
	love.graphics.setShader(pico8.draw_shader)
	love.graphics.setCanvas(pico8.screen)
	love.graphics.origin()
	api.camera()
	restore_clip()
	cartname = _cartname
	pico8.cart = cart.load_p8(_cartname)
end

function love.resize(w,h)
	love.graphics.clear()
	-- adjust stuff to fit the screen
	if w > h then
		scale = h/(pico8.resolution[2]+ypadding*2)
	else
		scale = w/(pico8.resolution[1]+xpadding*2)
	end
end

local function note_to_hz(note)
	return 440*math.pow(2,(note-33)/12)
end

function love.load(argv)
	love_args = argv
	if love.system.getOS() == "Android" then
		love.resize(love.window.getDimensions())
	else
		love.window.setMode(pico8.resolution[1]*scale+xpadding*scale*2,pico8.resolution[2]*scale+ypadding*scale*2)
	end

	osc = {}
	-- tri
	osc[0] = function(x)
		local t = x%1
		return (abs(t*2-1)*2-1) * 2/3
	end
	-- uneven tri
	osc[1] = function(x)
		local t = x%1
		return (((t < 0.875) and (t * 16 / 7) or ((1-t)*16)) -1) * 0.6
	end
	-- saw
	osc[2] = function(x)
		return (x%1-0.5) * 0.9
	end
	-- sqr
	osc[3] = function(x)
		return (x%1 < 0.5 and 1 or -1) * 1/3
	end
	-- pulse
	osc[4] = function(x)
		return (x%1 < 0.3 and 1 or -1) * 1/3
	end
	-- tri/2
	osc[5] = function(x)
		x = x * 4
		return (abs((x%2)-1)-0.5 + (abs(((x*0.5)%2)-1)-0.5)/2-0.1)*0.7
	end
	osc[6] = function()
		-- noise FIXME: (zep said this is brown noise)
		local lastx = 0
		local sample = 0
		local lsample = 0
		local tscale = note_to_hz(63)/__sample_rate
		return function(x)
			local scale = (x-lastx)/tscale
			lsample = sample
			sample = (lsample+scale*(love.math.random()*2-1))/(1+scale)
			lastx = x
			return math.min(math.max((lsample+sample)*4/3*(1.75-scale),-1),1)
		end
	end
	-- detuned tri
	osc[7] = function(x)
		x = x * 2
		return (abs((x%2)-1)-0.5 + (abs(((x*0.97)%2)-1)-0.5)/2) * 2/3
	end
	-- saw from 0 to 1, used for arppregiator
	osc["saw_lfo"] = function(x)
		return x%1
	end

	__audio_channels = {
		[0]=QueueableSource:new(8),
		QueueableSource:new(8),
		QueueableSource:new(8),
		QueueableSource:new(8)
	}

	for i=0,3 do
		__audio_channels[i]:play()
		pico8.audio_channels[i].noise = osc[6]()
	end

	love.graphics.setBackgroundColor(3, 5, 10, 255)
	love.graphics.clear()
	love.graphics.setDefaultFilter('nearest','nearest')
	pico8.screen = love.graphics.newCanvas(pico8.resolution[1],pico8.resolution[2])
	pico8.screen:setFilter('linear','nearest')

	local glyphs = ""
	for i = 32,126 do
		glyphs = glyphs..string.char(i)
	end
	local font = love.graphics.newImageFont("font.png",glyphs,1)
	love.graphics.setFont(font)
	font:setFilter('nearest','nearest')

	love.mouse.setVisible(false)
	love.window.setTitle("picolove")
	love.graphics.setLineStyle('rough')
	love.graphics.setPointSize(1)
	love.graphics.setLineWidth(1)

	love.graphics.origin()
	love.graphics.setCanvas(pico8.screen)
	restore_clip()

	pico8.draw_palette = {}
	pico8.display_palette = {}
	pico8.pal_transparent = {}
	for i=1,16 do
		pico8.draw_palette[i] = i
		pico8.pal_transparent[i] = i == 1 and 0 or 1
		pico8.display_palette[i] = pico8.palette[i]
	end

	pico8.draw_shader = love.graphics.newShader([[
extern float palette[16];

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	int index = int(color.r*16.0);
	return vec4(vec3(palette[index]/16.0),1.0);
}]])
	pico8.draw_shader:send('palette',unpack(pico8.draw_palette))

	pico8.sprite_shader = love.graphics.newShader([[
extern float palette[16];
extern float transparent[16];

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	int index = int(floor(Texel(texture, texture_coords).r*16.0));
	float alpha = transparent[index];
	return vec4(vec3(palette[index]/16.0),alpha);
}]])
	pico8.sprite_shader:send('palette',unpack(pico8.draw_palette))
	pico8.sprite_shader:send('transparent',unpack(pico8.pal_transparent))

	pico8.text_shader = love.graphics.newShader([[
extern float palette[16];

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 texcolor = Texel(texture, texture_coords);
	if(texcolor.a == 0) {
		return vec4(0.0,0.0,0.0,0.0);
	}
	int index = int(color.r*16.0);
	// lookup the colour in the palette by index
	return vec4(vec3(palette[index]/16.0),1.0);
}]])
	pico8.text_shader:send('palette',unpack(pico8.draw_palette))

	pico8.display_shader = love.graphics.newShader([[

extern vec4 palette[16];

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	int index = int(Texel(texture, texture_coords).r*15.0);
	// lookup the colour in the palette by index
	return palette[index]/256.0;
}]])
	pico8.display_shader:send('palette',unpack(pico8.display_palette))

	api=require("api")
	cart=require("cart")

	-- load the cart
	api.clip()
	api.camera()
	api.pal()
	api.palt()
	api.color(6)

	_load(argv[2] or 'nocart.p8')
	api.run()
end

function love.update(dt)
	for p=0,1 do
		for i=0,#pico8.keymap[p] do
			for _,key in pairs(pico8.keymap[p][i]) do
				local v = pico8.keypressed[p][i]
				if v then
					v = v + 1
					pico8.keypressed[p][i] = v
					break
				end
			end
		end
	end
	if pico8.cart._update then pico8.cart._update() end
end

function restore_camera()
	love.graphics.origin()
	love.graphics.translate(-pico8.camera_x,-pico8.camera_y)
end

local function flip_screen()
	--love.graphics.setShader(pico8.display_shader)
	love.graphics.setShader(pico8.display_shader)
	pico8.display_shader:send('palette',unpack(pico8.display_palette))
	love.graphics.setCanvas()
	love.graphics.origin()

	-- love.graphics.setColor(255,255,255,255)
	love.graphics.setScissor()

	love.graphics.clear()

	local screen_w,screen_h = love.graphics.getDimensions()
	if screen_w > screen_h then
		love.graphics.draw(pico8.screen,screen_w/2-64*scale,ypadding*scale,0,scale,scale)
	else
		love.graphics.draw(pico8.screen,xpadding*scale,screen_h/2-64*scale,0,scale,scale)
	end

	love.graphics.present()

	if video_frames then
		local tmp = love.graphics.newCanvas(pico8.resolution[1],pico8.resolution[2])
		love.graphics.setCanvas(tmp)
		love.graphics.draw(pico8.screen,0,0)
		table.insert(video_frames,tmp:newImageData())
	end
	-- get ready for next time
	love.graphics.setShader(pico8.draw_shader)
	love.graphics.setCanvas(pico8.screen)
	restore_clip()
	restore_camera()
end

local function lowpass(y0,y1, cutoff)
	local RC = 1.0/(cutoff*2*3.14)
	local dt = 1.0/__sample_rate
	local alpha = dt/(RC+dt)
	return y0 + (alpha*(y1 - y0))
end

local note_map = {
	[0] = 'C-',
		  'C#',
		  'D-',
		  'D#',
		  'E-',
		  'F-',
		  'F#',
		  'G-',
		  'G#',
		  'A-',
		  'A#',
		  'B-',
}

local function note_to_string(note)
	local octave = flr(note/12)
	local note = flr(note%12)
	return string.format("%s%d",note_map[note],octave)
end

local function oldosc(osc)
	local x = 0
	return function(freq)
		x = x + freq/__sample_rate
		return osc(x)
	end
end

local function lerp(a,b,t)
	return (b-a)*t+a
end

function update_audio(time)
	-- check what sfx should be playing
	local samples = flr(time*__sample_rate)

	for i=0,samples-1 do
		if pico8.current_music then
			pico8.current_music.offset = pico8.current_music.offset + 1/(48*15.25)*(1/pico8.current_music.speed*4)
			if pico8.current_music.offset >= 32 then
				local next_track = pico8.current_music.music
				if pico8.music[next_track].loop == 2 then
					-- go back until we find the loop start
					while true do
						if pico8.music[next_track].loop == 1 or next_track == 0 then
							break
						end
						next_track = next_track - 1
					end
				elseif pico8.music[pico8.current_music.music].loop == 4 then
					next_track = nil
				elseif pico8.music[pico8.current_music.music].loop <= 1 then
					next_track = next_track + 1
				end
				if next_track then
					api.music(next_track)
				end
			end
		end
		local music = pico8.current_music and pico8.music[pico8.current_music.music] or nil

		for channel=0,3 do
			local ch = pico8.audio_channels[channel]
			local tick = 0
			local tickrate = 60*16
			local note,instr,vol,fx
			local freq

			if ch.bufferpos == 0 or ch.bufferpos == nil then
				ch.buffer = love.sound.newSoundData(__audio_buffer_size,__sample_rate,bits,channels)
				ch.bufferpos = 0
			end
			if ch.sfx and pico8.sfx[ch.sfx] then
				local sfx = pico8.sfx[ch.sfx]
				ch.offset = ch.offset + 1/(48*15.25)*(1/sfx.speed*4)
				if sfx.loop_end ~= 0 and ch.offset >= sfx.loop_end then
					if ch.loop then
						ch.last_step = -1
						ch.offset = sfx.loop_start
					else
						pico8.audio_channels[channel].sfx = nil
					end
				elseif ch.offset >= 32 then
					pico8.audio_channels[channel].sfx = nil
				end
			end
			if ch.sfx and pico8.sfx[ch.sfx] then
				local sfx = pico8.sfx[ch.sfx]
				-- when we pass a new step
				if flr(ch.offset) > ch.last_step then
					ch.lastnote = ch.note
					ch.note,ch.instr,ch.vol,ch.fx = unpack(sfx[flr(ch.offset)])
					if ch.instr ~= 6 then
						ch.osc = osc[ch.instr]
					else
						ch.osc = ch.noise
					end
					if ch.fx == 2 then
						ch.lfo = oldosc(osc[0])
					elseif ch.fx >= 6 then
						ch.lfo = oldosc(osc["saw_lfo"])
					end
					if ch.vol > 0 then
						ch.freq = note_to_hz(ch.note)
					end
					ch.last_step = flr(ch.offset)
				end
				if ch.vol and ch.vol > 0 then
					local vol = ch.vol
					if ch.fx == 1 then
						-- slide from previous note over the length of a step
						ch.freq = lerp(note_to_hz(ch.lastnote or 0),note_to_hz(ch.note),ch.offset%1)
					elseif ch.fx == 2 then
						-- vibrato one semitone?
						ch.freq = lerp(note_to_hz(ch.note),note_to_hz(ch.note+0.5),ch.lfo(4))
					elseif ch.fx == 3 then
						-- drop/bomb slide from note to c-0
						local off = ch.offset%1
						--local freq = lerp(note_to_hz(ch.note),note_to_hz(0),off)
						local freq = lerp(note_to_hz(ch.note),0,off)
						ch.freq = freq
					elseif ch.fx == 4 then
						-- fade in
						vol = lerp(0,ch.vol,ch.offset%1)
					elseif ch.fx == 5 then
						-- fade out
						vol = lerp(ch.vol,0,ch.offset%1)
					elseif ch.fx == 6 then
						-- fast appreggio over 4 steps
						local off = bit.band(flr(ch.offset),0xfc)
						local lfo = flr(ch.lfo(8)*4)
						off = off + lfo
						local note = sfx[flr(off)][1]
						ch.freq = note_to_hz(note)
					elseif ch.fx == 7 then
						-- slow appreggio over 4 steps
						local off = bit.band(flr(ch.offset),0xfc)
						local lfo = flr(ch.lfo(4)*4)
						off = off + lfo
						local note = sfx[flr(off)][1]
						ch.freq = note_to_hz(note)
					end
					ch.sample = ch.osc(ch.oscpos) * vol/7
					ch.oscpos = ch.oscpos + ch.freq/__sample_rate
					ch.buffer:setSample(ch.bufferpos,ch.sample)
				else
					ch.buffer:setSample(ch.bufferpos,lerp(ch.sample or 0,0,0.1))
					ch.sample = 0
				end
			else
				ch.buffer:setSample(ch.bufferpos,lerp(ch.sample or 0,0,0.1))
				ch.sample = 0
			end
			ch.bufferpos = ch.bufferpos + 1
			if ch.bufferpos == __audio_buffer_size then
				-- queue buffer and reset
				__audio_channels[channel]:queue(ch.buffer)
				__audio_channels[channel]:play()
				ch.bufferpos = 0
			end
		end
	end
end

function love.draw()
	love.graphics.setCanvas(pico8.screen)
	restore_clip()
	restore_camera()

	love.graphics.setShader(pico8.draw_shader)

	-- run the cart's draw function
	if pico8.cart._draw then pico8.cart._draw() end

	-- draw the contents of pico screen to our screen
	flip_screen()
end

function _reload()
	_load(cartname)
	run()
end

function love.keypressed(key)
	if cart and pico8.cart._keydown then
		return pico8.cart._keydown(key)
	end
	if key == 'r' and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('lgui')) then
		_reload()
	elseif key == 'q' and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('lgui')) then
		love.event.quit()
	elseif key == 'pause' then
		paused = not paused
	elseif key == 'f6' then
		-- screenshot
		local screenshot = love.graphics.newScreenshot(false)
		local filename = cartname..'-'..os.time()..'.png'
		screenshot:encode(filename)
		log('saved screenshot to',filename)
	elseif key == 'f8' then
		-- start recording
		video_frames = {}
	elseif key == 'f9' then
		-- stop recording and save
		local basename = cartname..'-'..os.time()..'-'
		for i,v in ipairs(video_frames) do
			v:encode(string.format("%s%04d.png",basename,i))
		end
		video_frames = nil
		log('saved video to',basename)
	else
		for p=0,1 do
			for i=0,#pico8.keymap[p] do
				for _,testkey in pairs(pico8.keymap[p][i]) do
					if key == testkey then
						pico8.keypressed[p][i] = -1 -- becomes 0 on the next frame
						break
					end
				end
			end
		end
	end
end

function love.keyreleased(key)
	if cart and pico8.cart._keyup then
		return pico8.cart._keyup(key)
	end
	for p=0,1 do
		for i=0,#pico8.keymap[p] do
			for _,testkey in pairs(pico8.keymap[p][i]) do
				if key == testkey then
					pico8.keypressed[p][i] = nil
					break
				end
			end
		end
	end
end

function love.textinput(text)
	if cart and pico8.cart._textinput then return pico8.cart._textinput(text) end
end

function love.graphics.point(x,y)
	love.graphics.rectangle('fill',x,y,1,1)
end

function setfps(fps)
	pico8.fps = flr(fps)
	if pico8.fps <= 0 then
		pico8.fps = 30
	end
	frametime = 1/pico8.fps
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end
	math.randomseed(os.time())
	for i=1,3 do math.random() end

	if love.event then
		love.event.pump()
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[e](a,b,c,d)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = dt + love.timer.getDelta()
		end

		-- Call update and draw
		local render = false
		while dt > frametime do
			host_time = host_time + dt
			if paused then
			else
				if love.update then love.update(frametime) end -- will pass 0 if love.timer is disabled
				update_audio(frametime)
			end
			dt = dt - frametime
			render = true
		end

		if render and love.window and love.graphics and love.window.isCreated() then
			love.graphics.origin()
			if paused then
				api.rectfill(64-4*4,60,64+4*4-2,64+4+4,1)
				api.print("paused",64 - 3*4,64,(host_time*20)%8<4 and 7 or 13)
				flip_screen()
			else
				if love.draw then love.draw() end
			end
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end
