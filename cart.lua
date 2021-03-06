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


	pico8.spritesheet_table={}
	for i =0, 127 do
		pico8.spritesheet_table[i] = {}
		for j = 0, 127 do
			pico8.spritesheet_table[i][j] = 0
		end
	end
	pico8.spritesheet_pointsByColor={}

	pico8.map={}
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

	--no support for pngs yet
	local f=love.filesystem.newFile(filename, 'r')
	if not f and filename:sub(1, 5) == "game/" then
		--if running in regular love, it won't be in the game directory
		filename = filename:sub(5)
		f=love.filesystem.newFile(filename, 'r')
	end

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

	--get sprite sheet data and store in table
	local gfxdata=data:match("\n__gfx__.-\n(.-\n)\n-__")
	if gfxdata then
		local row=0

		for line in gfxdata:gmatch("(.-)\n") do
			local col=0
			for v in line:gmatch(".") do
				v=tonumber(v, 16)
				pico8.spritesheet_table[col][row] = v

				local point = {col, row}

				if pico8.spritesheet_pointsByColor[v] == nil then
					pico8.spritesheet_pointsByColor[v] = {}
				end

				pico8.spritesheet_pointsByColor[v][#pico8.spritesheet_pointsByColor[v]+1]=point

				col=col+1
				if col==128 then break end
			end
			row=row+1
			if row==128 then break end
		end
	end

	--convert spritesheet table into canvas
	pico8.spritesheet_data=getSpritesheetCanvas()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas()

	local shared=0

	
	if version>3 then
		local tx, ty=0, 32
		for sy=64, 127 do
			for sx=0, 127, 2 do
				-- get the two pixel values and merge them
				local lo=pico8.spritesheet_table[sx][sy]
				local hi=pico8.spritesheet_table[sx+1][sy]
				local v=bit.bor(bit.lshift(hi, 4), lo)
				pico8.map[ty][tx]=v
				shared=shared+1
				tx=tx+1
				if tx==128 then
					tx=0
					ty=ty+1
				end
			end
		end
	end
	
	local os = love.system.getOS()
	local offset = 0;
	if os ~= "3DS" and os ~= "Horizon" then
		offset = -1
	end

	-- generate a quad for each sprite index
	for y=0, 15 do
		for x=0, 15 do
			pico8.quads[y*16+x]=love.graphics.newQuad(8*x + offset, 8*y + offset, 8, 8, 128, 128)
		end
	end

	-- load the sprite flags
	local gffdata=data:match("\n__gff__.-\n(.-\n)\n-__")

	if gffdata then
		local sprite=0
		local gffpat=(version<=2 and "." or "..")

		for line in gffdata:gmatch("(.-)\n") do
			local col=0

			for v in line:gmatch(gffpat) do
				v=tonumber(v, 16)
				pico8.spriteflags[sprite+col]=v
				col=col+1
				if col==128 then break end
			end

			sprite=sprite+128
			if sprite==256 then break end
		end
	end

	-- convert the tile data to a table
	local mapdata=data:match("\n__map__.-\n(.-\n)\n-__")

	if mapdata then
		local row=0
		local tiles=0

		for line in mapdata:gmatch("(.-)\n") do
			local col=0
			for v in line:gmatch("..") do
				v=tonumber(v, 16)
				pico8.map[row][col]=v
				col=col+1
				tiles=tiles+1
				if col==128 then break end
			end
			row=row+1
			if row==32 then break end
		end
	end

	--store data in cart section of pico8 for reload if necessary
	pico8.cartrom.spritesheet_table={}
	for i =0, 127 do
		pico8.cartrom.spritesheet_table[i] = {}
		for j = 0, 127 do
			pico8.cartrom.spritesheet_table[i][j] = pico8.spritesheet_table[i][j]
		end
	end

	pico8.cartrom.map={}
	for y=0, 63 do
		pico8.cartrom.map[y]={}
		for x=0, 127 do
			pico8.cartrom.map[y][x]=pico8.map[y][x]
		end
	end

	pico8.cartrom.spriteflags={}
	for i=0, 255 do
		pico8.cartrom.spriteflags[i]=pico8.spriteflags[i]
	end

	-- patch the lua
	lua=lua:gsub("!=", "~=").."\n"
	-- rewrite shorthand if statements eg. if (not b) i=1 j=2
	lua=lua:gsub("if%s*(%b())%s*([^\n]*)\n", function(a, b)
		local nl=a:find('\n', nil, true)
		local th=b:find('%f[%w]then%f[%W]')
		local an=b:find('%f[%w]and%f[%W]')
		local o=b:find('%f[%w]or%f[%W]')
		local ce=b:find('--', nil, true)
		if not (nl or th or an or o) then
			if ce then
				local c, t=b:match("(.-)(%s-%-%-.*)")
				return "if "..a:sub(2, -2).." then "..c.." end"..t.."\n"
			else
				return "if "..a:sub(2, -2).." then "..b.." end\n"
			end
		end
	end)
	-- rewrite assignment operators
	lua=lua:gsub("(%S+)%s*([%+-%*/%%])=", "%1 = %1 %2 ")
	-- convert binary literals to hex literals
	lua=lua:gsub("([^%w_])0[bB]([01.]+)", function(a, b)
		local p1, p2=b, ""
		if b:find('.', nil, true) then
			p1, p2=b:match("(.-)%.(.*)")
		end
		-- pad to 4 characters
		p2=p2..string.rep("0", 3-((#p2-1)%4))
		p1, p2=tonumber(p1, 2), tonumber(p2, 2)
		if p1 and p2 then
			return string.format("%s0x%x.%x", a, p1, p2)
		end
	end)

	local cart_env={}
	for k, v in pairs(api) do
		cart_env[k]=v
	end
	cart_env.lua = lua
	cart_env._ENV=cart_env -- Lua 5.2 compatibility hack

	updateStatus('load patched lua')
	local ok, f, e=pcall(loadstring, lua, "@"..filename)

	if not ok or f==nil then
		local ln=1
		lua="1:"..lua:gsub("\n", function(a) ln=ln+1 return "\n"..ln..":" end)
		--updateStatus('=======8<========')
		--updateStatus(lua)
		--write the lua we're actually using for debug purposes
		local name = "parsed.lua"
		local myFile = love.filesystem.newFile(name, "w")
		myFile:write(lua)
		myFile:flush()
		myFile:close()
		--updateStatus('=======>8========')
		--force show debug info if the cart doesn't load
		toggleShowDebugInfo(true)
		updateStatus("Error loading lua (writing parsed lua to disk): "..tostring(e),0)
	else
		local result
		updateStatus('pcalling patched lua')
		setfenv(f, cart_env)
		love.graphics.setCanvas(pico8.screen)
		love.graphics.clear()
		love.graphics.origin()
		restore_clip()
		ok, result=pcall(f)
		if not ok then
			updateStatus("Error running lua: "..tostring(result))
		else
			updateStatus("lua completed")
		end
	end
	updateStatus("finished loading cart", filename)

	love.graphics.setCanvas()
	return cart_env

end

return cart
