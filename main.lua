--!!!!EDIT HERE TO LOAD A DIFFERENT CART!!!!--
local cartPath = 'game/otherTestGames/mrblast.p8'

pico8={
	fps=30,
	frames=0,
	resolution={128, 128},
	palette={
		{0,      0,      0,      1},
		{29/255, 43/255, 83/255, 1},
		{126/255,37/255, 83/255, 1},
		{0,      135/255,81/255, 1},
		{171/255,82/255, 54/255, 1},
		{95/255, 87/255, 79/255, 1},
		{194/255,195/255,199/255,1},
		{1,      241/255,232/255,1},
		{1,      0,      77/255, 1},
		{1,      163/255,0,      1},
		{1,      240/255,36/255, 1},
		{0,      231/255,86/255, 1},
		{41/255, 173/255,1      ,1},
		{131/255,118/255,156/255,1},
		{1,      119/255,168/255,1},
		{1,      204/255,170/255,1}
	},
	spriteflags={},
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
	cursor={0, 0},
	camera_x=0,
	camera_y=0,
	draw_palette={},
	display_palette={},
	pal_transparent={},
	spritesheet_cache={},
	cartrom={}
}

local function add(a, v)
	a[#a+1]=v
end

local function del(a, dv)
	for i=1, #a do
		if a[i]==dv then
			table.remove(a, i)
			return
		end
	end
end


local flr, abs=math.floor, math.abs
local lg = love.graphics

local frametime=1/pico8.fps
local cart=nil
local cartname=nil
local scale=5
local xpadding=320
local ypadding=40

local api, cart

local loveFrames = 0
local currentButtonDown = {}
local nthDrawFrame

--log=print
--log=function() end
local status = ''
local showDebugInfo = false
local exitKey

function updateStatus(newPart)
	status = status .. '\n' .. newPart
end

function toggleShowDebugInfo(isOn)
	showDebugInfo = isOn
end

function restore_clip()
	if pico8.clip then
		lg.setScissor(unpack(pico8.clip))
	else
		lg.setScissor()
	end
end

function setColor(c)
	c = c + 1
	lg.setColor(pico8.palette[c][1], pico8.palette[c][2], pico8.palette[c][3], 1)
end

function setShiftedColor(c, alphat)
	local pal_c = pico8.draw_palette[c]
	local alpha = 1
	if alphat then
		alpha = pico8.pal_transparent[c]
	end
	local colorIndex = pal_c + 1
	local color = pico8.palette[colorIndex]

	lg.setColor(color[1], color[2], color[3], alpha)
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
	lg.origin()
	pico8.clip=nil
	lg.setScissor()
	api.pal()
	pico8.color=6
	setColor(pico8.color)
	lg.setCanvas(pico8.screen)
	

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
		updateStatus('setting fps to 60')
		setfps(60)
	else
		updateStatus('setting fps to 30')
		setfps(30)
	end

	updateStatus('nthDrawFrame: ' .. nthDrawFrame)
end


function setfps(fps)
	pico8.fps=flr(fps)
	if pico8.fps<=0 then
		pico8.fps=30
	end

	if fps > 30 then
		nthDrawFrame = 1
	else
		nthDrawFrame = 2
	end

	frametime=1/pico8.fps
end


function love.load()
    local down, OS = "plus", {love.system.getOS()}
    if OS[2] == "3DS" then
        down = "start"
    end
	exitKey = down

	lg.clear()
	lg.setDefaultFilter('nearest', 'nearest')
	pico8.screen=lg.newCanvas(pico8.resolution[1], pico8.resolution[2])
	pico8.tmpscr=lg.newCanvas(pico8.resolution[1], pico8.resolution[2])

	--this runs initially, but font is not working... come back to this
	--local font=lg.newFont("PICO-8 mono.fnt", 1)
	--lg.setFont(font)
	pico8.fontImg = lg.newImage("font32bit.png")
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
        pico8.fontQuads[string.sub(glyphs, i, i)] = lg.newQuad((i-1)*4+1, 0, 3, 5, 593, 5)
    end

	--not implemented on switch
	if lg.setLineStyle then
		lg.setLineStyle('rough')
	end
	if lg.setPointsize then
		lg.setPointSize(1)
	end
	if lg.setLineWidth then
		lg.setLineWidth(1)
	end

	for i=0, 15 do
		pico8.draw_palette[i]=i
		pico8.pal_transparent[i]=i==0 and 0 or 1
		pico8.display_palette[i]=pico8.palette[i+1]
	end

	api=require("api")
	cart=require("cart")

	-- load the cart
	_load(cartPath)
end

function paletteKey()
	--third way should be better
	local t = {}
	for i=1, 16 do
		local index = ((i - 1) * 2) + 1
		t[index] = pico8.draw_palette[i - 1]
		t[index + 1] = pico8.pal_transparent[i - 1]
	end
	return table.concat(t, "")
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

	local canvas = lg.newCanvas(128, 128)

	pico8.spritesheet_cache[currentPalKey] = canvas
	lg.setCanvas(canvas)
	--workaround for bug in current lovepotion (5/2/19)
	lg.clear()
	--need to call this in case the camera has moved, we don't want our spritesheet offset
	lg.origin()
	

	for c, table in pairs(pico8.spritesheet_pointsByColor) do
		if table ~= nil then
			setShiftedColor(c, true)

			lg.points(table)
		end
	end

	lg.setCanvas()
	restore_camera()

	return canvas
end


function love.update(dt)
	if loveFrames % nthDrawFrame == 0 then
		pico8.frames=pico8.frames+1

		update_buttons()

		if pico8.cart._update60 then
			pico8.cart._update60()
		elseif pico8.cart._update then
			pico8.cart._update()
		end
	end
	loveFrames = loveFrames + 1
end

function love.draw()
	if loveFrames % nthDrawFrame == 0  then
		lg.setCanvas(pico8.screen)

		if pico8.cart._draw then 
			pico8.cart._draw() 
		end
	end

	flip_screen()
end

function restore_camera()
	lg.origin()
	lg.translate(-pico8.camera_x, -pico8.camera_y)
end

function flip_screen()
	lg.setCanvas()
	lg.origin()
	lg.setScissor()

	lg.clear()

	--lg.print(love.system.getOS(), 0, 0)

	if showDebugInfo then
		lg.print(status, 0, 10)
	end


	local r, g, b, a = lg.getColor()
	lg.setColor(1, 1, 1)
	lg.draw(pico8.screen, xpadding, ypadding, 0, scale, scale)
	lg.setColor(r, g, b, a)

	-- get ready for next time
	--setting canvas here doesn't work for lovePotion. 
	--we do it just before calling _draw() instead, but that may cause problems
	--lg.setCanvas(pico8.screen)
	restore_clip()
	restore_camera()
end

function love.gamepadpressed(joy, button)
    if button == exitKey then
        love.event.quit()
    else
		add(currentButtonDown, button)
    end
end

function love.gamepadreleased(joy, button)
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