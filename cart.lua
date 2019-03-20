local api=require("api")

local compression_map={}
for entry in ("\n 0123456789abcdefghijklmnopqrstuvwxyz!#%(){}[]<>+=/*:;.,~_"):gmatch(".") do
	table.insert(compression_map, entry)
end

local cart={}

function cart.load_p8(filename)
	updateStatus('Loading cart')

	local lua=""
	pico8.quads={}
	pico8.spritesheet_data=love.graphics.newCanvas()
	--turn it all black
	--pico8.spritesheet_data:mapPixel(function() return 0, 0, 0, 1 end)
	pico8.map={}
	updateStatus('setting initial cart table state')
	for y=0, 63 do
		pico8.map[y]={}
		for x=0, 127 do
			pico8.map[y][x]=0
		end
	end
	pico8.spriteflags={}
	for i=0, 255 do
		pico8.spriteflags[i]=0
	end
	pico8.sfx={}
	for i=0, 63 do
		pico8.sfx[i]={
			editor_mode=0,
			speed=16,
			loop_start=0,
			loop_end=0
		}
		for j=0, 31 do
			pico8.sfx[i][j]={0, 0, 0, 0}
		end
	end
	pico8.music={}
	for i=0, 63 do
		pico8.music[i]={
			loop=0,
			[0]=65,
			[1]=66,
			[2]=67,
			[3]=68
		}
	end

	--no support for pngs yet
	--local f=love.filesystem.newFile(filename, 'r')
	f=love.filesystem.newFile(filename, 'r')
	if not f then
		error(string.format("Unable to open: %s", filename))
	end
	
	local data, size=f:read()
	f:close()

	if not data then
		error("invalid cart")
	end
	updateStatus('have valid cart')
	-- strip carriage returns pico-8 style
	data=data:gsub("\r.", "\n")
	

	-- tack on a fake header
	if data:sub(-1) ~= "\n" then
		data=data.."\n"
	end
	data=data.."__eof__\n"
	-- check for header and vesion
	local header="pico-8 cartridge // http://www.pico-8.com\nversion "
	local start=data:find("pico%-8 cartridge // http://www.pico%-8%.com\nversion ")
	if start==nil then
		error("invalid cart")
	end
	local next_line=data:find("\n", start+#header)
	local version_str=data:sub(start+#header, next_line-1)
	local version=tonumber(version_str)
	updateStatus("version " .. version)
	-- extract the lua
	lua=data:match("\n__lua__.-\n(.-)\n__") or ""
	-- load the sprites into an imagedata
	-- generate a quad for each sprite index
	local gfxdata=data:match("\n__gfx__.-\n(.-\n)\n-__")

	testChar = 'notyet'
	testNum = 0

	if gfxdata then
		local row=0
		--love.graphics.setCanvas(pico8.spritesheet_data)

		for line in gfxdata:gmatch("(.-)\n") do
			updateStatus(line)
			local col=0
			for v in line:gmatch(".") do
				testChar = v
				v=tonumber(v, 16)
				testNum = v
				--updateStatus(v)
				
				--local color = pico8.palette[v]
				--setColor(v)
				--love.graphics.setColor(color[1] / 255, color[2] / 255, color[3] / 255, 1)
				--love.graphics.points(col, row)

				--we can use this if imageData is implemented
				--pico8.spritesheet_data:setPixel(col, row, v/15, 0, 0, 1)
				col=col+1
				if col==128 then break end
			end
			row=row+1
			if row==128 then break end
		end

		--pico8.spritesheet_image = love.graphics.newImage(pico8.spritesheet_data:getImageData())
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas()

end

return cart
