pico8={
	fps=30,
	frames=0,
	pal_transparent={},
	resolution={128, 128},
	palette={
		{0,  0,  0,  255},
		{29, 43, 83, 255},
		{126,37, 83, 255},
		{0,  135,81, 255},
		{171,82, 54, 255},
		{95, 87, 79, 255},
		{194,195,199,255},
		{255,241,232,255},
		{255,0,  77, 255},
		{255,163,0,  255},
		{255,240,36, 255},
		{0,  231,86, 255},
		{41, 173,255,255},
		{131,118,156,255},
		{255,119,168,255},
		{255,204,170,255}
	},
	spriteflags={},
	audio_channels={},
	sfx={},
	music={},
	current_music=nil,
	usermemory={},
	cartdata={},
	clipboard="",
	keypressed={
		[0]={},
		[1]={},
		counter=0
	},
	kbdbuffer={},
	keymap={
		[0]={
			[0]={'left'},
			[1]={'right'},
			[2]={'up'},
			[3]={'down'},
			[4]={'z', 'c', 'n', 'kp-'},
			[5]={'x', 'v', 'm', '8'},
		},
		[1]={
			[0]={'s'},
			[1]={'f'},
			[2]={'e'},
			[3]={'d'},
			[4]={'tab', 'lshift'},
			[5]={'q', 'a'},
		}
	},
	mwheel=0,
	cursor={0, 0},
	camera_x=0,
	camera_y=0,
	draw_palette={},
	display_palette={},
	pal_transparent={},
}

--require("strict")
--local bit=require("bit")

--local flr, abs=math.floor, math.abs

local frametime=1/pico8.fps
local cart=nil
local cartname=nil
local love_args=nil
--local scale=nil
--local xpadding=nil
--local ypadding=nil
local scale=2
local xpadding=0
local ypadding=0

local tobase=nil
local topad=nil
local gif_recording=nil
local gif_canvas=nil
local osc
local host_time=0
local retro_mode=false
local paused=false
local mobile=false
local api, cart, gif

local __buffer_count=8
local __buffer_size=1024
local __sample_rate=22050
local channels=1
local bits=16

--log=print
--log=function() end


function setColor(c)
	love.graphics.setColor(c/15, 0, 0, 1)
end

local exts={"", ".p8"}
function _load(filename)
	filename=filename or cartname
	for i=1, #exts do
		if love.filesystem.getInfo(filename..exts[i]) ~= nil then
			filename=filename..exts[i]
			break
		end
	end
	cartname=filename

	--[[
	pico8.camera_x=0
	pico8.camera_y=0
	love.graphics.origin()
	pico8.clip=nil
	love.graphics.setScissor()
	api.pal()
	pico8.color=6
	setColor(pico8.color)
	love.graphics.setCanvas(pico8.screen)
	love.graphics.setShader(pico8.draw_shader)

	pico8.cart=cart.load_p8(filename)
	for i=0, 0x1c00-1 do
		pico8.usermemory[i]=0
	end
	for i=0, 63 do
		pico8.cartdata[i]=0
	end
	if pico8.cart._init then pico8.cart._init() end
	if pico8.cart._update60 then
		setfps(60)
	else
		setfps(30)
	end
	]]
end

function love.resize(w, h)
	--[[
	love.graphics.clear()
	-- adjust stuff to fit the screen
	scale=math.max(math.min(w/pico8.resolution[1], h/pico8.resolution[2]), 1)
	if not mobile then
		scale=math.floor(scale)
	end
	xpadding=(w-pico8.resolution[1]*scale)/2
	ypadding=(h-pico8.resolution[2]*scale)/2
	tobase=math.min(w, h)/9
	topad=tobase/8

	]]
end

function love.load(argv)
	love_args=argv

	--love.resize(love.graphics.getDimensions()) -- Setup initial scaling and padding

	love.graphics.clear()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	pico8.screen=love.graphics.newCanvas(pico8.resolution[1], pico8.resolution[2])
	pico8.tmpscr=love.graphics.newCanvas(pico8.resolution[1], pico8.resolution[2])

	--[[
	local glyphs=""
	for i=32, 127 do
		glyphs=glyphs..string.char(i)
	end
	for i=128, 153 do
		glyphs=glyphs..string.char(194, i)
	end
	local font=love.graphics.newImageFont("font.png", glyphs, 1)
	love.graphics.setFont(font)
	font:setFilter('nearest', 'nearest')

	love.graphics.setLineStyle('rough')
	love.graphics.setPointSize(1)
	love.graphics.setLineWidth(1)

	for i=0, 15 do
		pico8.draw_palette[i]=i
		pico8.pal_transparent[i]=i==0 and 0 or 1
		pico8.display_palette[i]=pico8.palette[i+1]
	end
	]]

	api=require("api")
	cart=require("cart")

	-- load the cart
	_load(argv[1] or 'xwing.p8')
end

local function inside(x, y, x0, y0, w, h)
	return (x>=x0 and x<x0+w and y>=y0 and y<y0+h)
end


local function update_buttons()
	local init, loop=pico8.fps/2, pico8.fps/7.5
	
	for p=0, 1 do
		local keymap=pico8.keymap[p]
		local keypressed=pico8.keypressed[p]
		for i=0, 5 do
			local btn=false
			for _, testkey in pairs(keymap[i]) do
				if love.keyboard.isDown(testkey) then
					btn=true
					break
				end
			end
			if not btn then
				keypressed[i]=false
			elseif not keypressed[i] then
				pico8.keypressed.counter=init
				keypressed[i]=true
			end
		end
	end
	pico8.keypressed.counter=pico8.keypressed.counter-1
	if pico8.keypressed.counter<=0 then
		pico8.keypressed.counter=loop
	end
end

function love.update(dt)
	pico8.frames=pico8.frames+1
	update_buttons()
	if pico8.cart._update60 then
		pico8.cart._update60()
	elseif pico8.cart._update then
		pico8.cart._update()
	end
end

function love.draw()
	-- run the cart's draw function
	if pico8.cart._draw then pico8.cart._draw() end
end

function restore_camera()
	love.graphics.origin()
	love.graphics.translate(-pico8.camera_x, -pico8.camera_y)
end

function flip_screen()
	love.graphics.setShader(pico8.display_shader)
	love.graphics.setCanvas()
	love.graphics.origin()
	love.graphics.setScissor()

	love.graphics.clear()

	love.graphics.draw(pico8.screen, xpadding, ypadding, 0, scale, scale)

	love.graphics.present()

	-- get ready for next time
	love.graphics.setShader(pico8.draw_shader)
	love.graphics.setCanvas(pico8.screen)
	restore_clip()
	restore_camera()
end

local function lerp(a, b, t)
	return (b-a)*t+a
end

function update_audio(buffer)

end

function love.keypressed(key)
	if cart and pico8.cart._keydown then
		return pico8.cart._keydown(key)
	end
end

function love.keyreleased(key)
	if cart and pico8.cart._keyup then
		return pico8.cart._keyup(key)
	end
end


function love.graphics.point(x, y)
	love.graphics.rectangle('fill', x, y, 1, 1)
end

function setfps(fps)
	pico8.fps=flr(fps)
	if pico8.fps<=0 then
		pico8.fps=30
	end
	frametime=1/pico8.fps
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1, 3 do love.math.random() end
	end
	math.randomseed(os.time())
	for i=1, 3 do math.random() end

	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	--[[
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt=0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.graphics.setCanvas() -- TODO: Rework this
			love.event.pump()
			love.graphics.setCanvas(pico8.screen) -- TODO: Rework this
			for name, a, b, c, d, e, f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a, b, c, d, e, f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt=dt+love.timer.step() end

		-- Call update and draw
		local render=false
		while dt>frametime do
			host_time=host_time+dt
			if paused then
			else
				if love.update then love.update(frametime) end -- will pass 0 if love.timer is disabled
			end
			dt=dt-frametime
			render=true
		end

		if render and love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			if paused then
				api.rectfill(64-4*4, 60, 64+4*4-2, 64+4+4, 1)
				api.print("paused", 64-3*4, 64, (host_time*20)%8<4 and 7 or 13)
			else
				if love.draw then love.draw() end
			end
			-- draw the contents of pico screen to our screen
			flip_screen()
			-- reset mouse wheel
			pico8.mwheel=0
		end

		if love.timer then love.timer.sleep(0.001) end
	end
	]]
end
