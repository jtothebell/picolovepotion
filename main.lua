pico8={
	fps=30,
	frames=0,
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
			[0]={'left', 'dpleft'},
			[1]={'right', 'dpright'},
			[2]={'up', 'dpup'},
			[3]={'down', 'dpdown'},
			[4]={'z', 'b'},
			[5]={'x', 'a'},
        },
        [1]={
			[0]={'s'},
			[1]={'f'},
			[2]={'e'},
			[3]={'d'},
			[4]={'tab'},
			[5]={'q'},
		}
	},
	mwheel=0,
	cursor={0, 0},
	camera_x=0,
	camera_y=0,
	draw_palette={},
	display_palette={},
	pal_transparent={},
	spritesheet_cache={}
}

function add(a, v)
	if a==nil then return end
	a[#a+1]=v
end

function del(a, dv)
	if a==nil then return end
	for i=1, #a do
		if a[i]==dv then
			table.remove(a, i)
			return
		end
	end
end

function btn(i, p)
	if i~=nil or p~=nil then
		p=p or 0
		if p<0 or p>1 then
			return false
		end
		return not not pico8.keypressed[p][i]
	else
		local bits=0
		for i=0, 5 do
			bits=bits+(pico8.keypressed[0][i] and 2^i or 0)
			bits=bits+(pico8.keypressed[1][i] and 2^(i+8) or 0)
		end
		return bits
	end
end

--require("strict")
--local bit=require("bit")

local flr, abs=math.floor, math.abs

local frametime=1/pico8.fps
local cart=nil
local cartname=nil
local love_args=nil
local xpadding=0
local ypadding=0
local scale=5
local xpadding=320
local ypadding=40

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
local loveFrames = 0

--log=print
--log=function() end
status = ''
showDebugInfo = false

function updateStatus(newPart)
	status = status .. '\n' .. newPart
end

function restore_clip()
	if pico8.clip then
		love.graphics.setScissor(unpack(pico8.clip))
	else
		love.graphics.setScissor()
	end
end

function setColor(c)
	c = c + 1
	love.graphics.setColor(pico8.palette[c][1] / 255, pico8.palette[c][2] / 255, pico8.palette[c][3] / 255, 1)
end

local exts={'', '.p8'}

function _load(filename)
	filename=filename or cartname
	for i=1, #exts do
		if love.filesystem.getInfo(filename..exts[i]) ~= nil then
			filename=filename..exts[i]
			break
		end
	end
	cartname=filename

	updateStatus('Setting up before load')

	pico8.camera_x=0
	pico8.camera_y=0
	love.graphics.origin()
	pico8.clip=nil
	love.graphics.setScissor()
	api.pal()
	pico8.color=6
	setColor(pico8.color)
	love.graphics.setCanvas(pico8.screen)
	

	updateStatus('calling load_p8 on ' .. filename)
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
end


function setfps(fps)
	pico8.fps=flr(fps)
	if pico8.fps<=0 then
		pico8.fps=30
	end
	frametime=1/pico8.fps
end


function love.load()

	currentButton =
    {
        pressed = 'None',
        released = 'None'
    }
	currentButtonDown = {}

    local down, OS = "plus", {love.system.getOS()}
    if OS[2] == "3DS" then
        down = "start"
    end
	exitKey = down
	
	--getDimensions not implemented yet
	--love.resize(love.graphics.getDimensions()) -- Setup initial scaling and padding

	love.graphics.clear()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	pico8.screen=love.graphics.newCanvas(pico8.resolution[1], pico8.resolution[2])
	pico8.tmpscr=love.graphics.newCanvas(pico8.resolution[1], pico8.resolution[2])

	--this runs initially, but font is not working... come back to this
	--local font=love.graphics.newFont("PICO-8 mono.fnt", 1)
	--love.graphics.setFont(font)
	pico8.fontImg = love.graphics.newImage("font32bit.png")
    pico8.fontQuads = {}

    local glyphs=""
	for i=32, 127 do
		glyphs=glyphs..string.char(i)
	end
	for i=128, 153 do
		glyphs=glyphs..string.char(194, i)
	end
	pico8.glyphs = glyphs
    for i = 1, #glyphs do
        pico8.fontQuads[string.sub(glyphs, i, i)] = love.graphics.newQuad((i-1)*4+1, 0, 3, 5, 593, 5)
    end

	--not implemented on switch
	if love.graphics.setLineStyle then
		love.graphics.setLineStyle('rough')
	end
	if love.graphics.setPointsize then
		love.graphics.setPointSize(1)
	end
	if love.graphics.setLineWidth then
		love.graphics.setLineWidth(1)
	end

	for i=0, 15 do
		pico8.draw_palette[i]=i
		pico8.pal_transparent[i]=i==0 and 0 or 1
		pico8.display_palette[i]=pico8.palette[i+1]
	end

	api=require("api")
	cart=require("cart")

	-- load the cart
	_load('game/otherTestGames/celeste.p8')
end

function paletteKey()
	local key = ""
	for k, v in pairs(pico8.draw_palette) do
		key = key .. v .. pico8.pal_transparent[k]
	end

	return key
end

function refreshSpritesheetCanvas()
	pico8.spritesheet_data = getSpritesheetCanvas()
end

function getSpritesheetCanvas()
	local currentPalKey = paletteKey()

	local cached = pico8.spritesheet_cache[currentPalKey]
	if cached ~= nil then
		return cached
	end

	local canvas = love.graphics.newCanvas(128, 128)
	local pointsByColor = {}

	pico8.spritesheet_cache[currentPalKey] = canvas
	love.graphics.setCanvas(canvas)
	
	for col =0, 127 do
		for row = 0, 127 do
			local c = pico8.spritesheet_table[col][row]

			local point = {x = col, y = row}

			if pointsByColor[c] == nil then
				pointsByColor[c] = {}
			end

			add(pointsByColor[c], point)

		end
	end

	for c, table in pairs(pointsByColor) do
		if table ~= nil then
			local pal_c = pico8.draw_palette[c]
			local colorIndex = pal_c + 1
			local alpha = pico8.pal_transparent[c]
			local color = pico8.palette[colorIndex]
			--setColor(v)

			love.graphics.setColor(color[1] / 255, color[2] / 255, color[3] / 255, alpha)

			--not sure why i can't just pass the table?! wtf
			local points = {}
			for i=1, #table do 
				local x = table[i].x
				local y = table[i].y
				points[i] = {x, y}
			end

			love.graphics.points(points)
		end
	end

	love.graphics.setCanvas()

	return canvas
end

function love.update(dt)
	--hack to force 30 fps. TODO: support 30 or 60
	if (loveFrames % 2 == 0) then
		pico8.frames=pico8.frames+1

		update_buttons()

		if pico8.cart._update then pico8.cart._update() end
	end
	loveFrames = loveFrames + 1
end

function love.draw()
	--hack to force 30 fps. TODO: support 30 or 60
	if (loveFrames % 2 == 0) then
		love.graphics.setCanvas(pico8.screen)

		if pico8.cart._draw then 
			pico8.cart._draw() 
		end
	end

	flip_screen()
end

function restore_camera()
	love.graphics.origin()
	love.graphics.translate(-pico8.camera_x, -pico8.camera_y)
end

function flip_screen()
	love.graphics.setCanvas()
	love.graphics.origin()
	love.graphics.setScissor()

	love.graphics.clear()

	love.graphics.print(love.system.getOS(), 0, 0)

	if showDebugInfo then
		local i = 0
		for k, v in pairs(currentButton) do
			love.graphics.print(k .. ": " .. v, 1000, 100 + (i * 18))
			i = i + 1
		end
		
		love.graphics.print(status, 0, 10)
	end

	love.graphics.draw(pico8.screen, xpadding, ypadding, 0, scale, scale)

	-- get ready for next time
	--setting canvas here doesn't work for lovePotion. 
	--we do it just before calling _draw() instead, but that may cause problems
	--love.graphics.setCanvas(pico8.screen)
	restore_clip()
	restore_camera()
end

function love.gamepadpressed(joy, button)
    if button == exitKey then
        love.event.quit()
    else
        currentButton.pressed = button
		add(currentButtonDown, button)
    end
end

function love.gamepadreleased(joy, button)
    currentButton.released = button
	del(currentButtonDown, button)
end

function update_buttons()
	local init, loop=pico8.fps/2, pico8.fps/7.5
	
	for p=0, 1 do
		local keymap=pico8.keymap[p]
		local keypressed=pico8.keypressed[p]
		for i=0, 5 do
			local btn=false
			for _, testkey in pairs(keymap[i]) do
				if love.keyboard and love.keyboard.isDown and testkey:sub(1, 2) ~= "dp" then
					if love.keyboard.isDown(testkey) then
						btn=true
						break
					end
				elseif currentButtonDown then
					for _, btnDwn in pairs(currentButtonDown) do
						if btnDwn == testkey then
							btn = true
						end
					end
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