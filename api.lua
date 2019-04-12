local flr=math.floor

local function color(c)
	c=flr(c or 0)%16
	pico8.color=c
	setColor(c)
end

local function warning(msg)
	updateStatus("WARNING: "..msg)
end

local function _horizontal_line(lines, x0, y, x1)
	table.insert(lines, {x0+0.5, y+0.5, x1+1.5, y+0.5})
end

local function _plot4points(lines, cx, cy, x, y)
	_horizontal_line(lines, cx-x, cy+y, cx+x)
	if y~=0 then
		_horizontal_line(lines, cx-x, cy-y, cx+x)
	end
end
--------------------------------------------------------------------------------
-- PICO-8 API

local api={}

function api.flip()

end

function api.camera(x, y)

end

function api.clip(x, y, w, h)

end

function api.cls(c)
	c = tonumber(c) or 0
	if c == nil then
		c = 0
	end

	pico8.clip=nil
	--size of pico 8 screen
	love.graphics.setScissor()
	--TODO clear the color passed
	local color = pico8.palette[c + 1]
	--love.graphics.clear(color[1] / 255, color[2] / 255, color[3] / 255, 1)
	--pico love uses the background color for clear. This doesn't match love behavior
	love.graphics.setBackgroundColor(color[1] / 255, color[2] / 255, color[3] / 255)
	love.graphics.clear()
	pico8.cursor={0, 0}

end

function api.folder()
end

function api.ls()
end
--api.dir=api.ls

function api.cd()
end

function api.mkdir()
end

function api.install_demos()
end

function api.install_games()
end

function api.keyconfig()
end

function api.splore()
end

function api.pset(x, y, c)
	if c then
		color(c)
	end
	love.graphics.points(flr(x), flr(y))
end

function api.pget(x, y)

end

function api.color(c)
	color(c)
end

function api.print(str, x, y, col)
	local prevCol = pico8.color
	if col then
		color(col)
	end

	if x and y then
		pico8.cursor[1]=flr(tonumber(x) or 0)
		pico8.cursor[2]=flr(tonumber(y) or 0)
	end
	
	local str=tostring(str):gsub("[%z\1-\9\11-\31\154-\255]", " "):gsub("[\128-\153]", "\194%1").."\n"
	local size=0

	for line in str:gmatch("(.-)\n") do
		local xAdd = 0
    	for i = 1, #tostring(line) do
        	love.graphics.draw(pico8.fontImg, pico8.fontQuads[string.sub(line, i, i)], pico8.cursor[1]+xAdd, pico8.cursor[2]+size)
        	xAdd = xAdd + 4
    	end
		size=size+5
	end

	--[[
	if not x and not y then
		if pico8.cursor[2]+size>122 then
			love.graphics.setShader()
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.setCanvas(pico8.tmpscr)
			love.graphics.draw(pico8.screen)
			love.graphics.setCanvas(pico8.screen)
			love.graphics.draw(pico8.tmpscr, 0, -size)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", 0, pico8.resolution[2]-size, pico8.resolution[1], size)
			setColor(pico8.color)
		else
			pico8.cursor[2]=pico8.cursor[2]+size
		end
	end
	love.graphics.setShader(pico8.draw_shader)
	--]]

	if prevCol then
		color(prevCol)
	end
end

api.printh=print

function api.cursor(x, y)
	pico8.cursor={x or 0, y or 0}
end

function api.tonum(val)
	return tonumber(val) -- not a direct assignment to prevent usage of the radix argument
end

function api.tostr(val, hex)

end

function api.spr(n, x, y, w, h, flip_x, flip_y)
	--love.graphics.setShader(pico8.sprite_shader)
	n=flr(n)
	w=w or 1
	h=h or 1
	local q
	if w==1 and h==1 then
		q=pico8.quads[n]
		if not q then
			updateStatus('warning: sprite '..n..' is missing')
			return
		end
	else
		local id=string.format("%d-%d-%d", n, w, h)
		if pico8.quads[id] then
			q=pico8.quads[id]
		else
			q=love.graphics.newQuad(flr(n%16)*8, flr(n/16)*8, 8*w, 8*h, 128, 128)
			pico8.quads[id]=q
		end
	end
	if not q then
		updateStatus('missing quad', n)
	end
	love.graphics.draw(pico8.spritesheet_data, q,
		flr(x)+(w*8*(flip_x and 1 or 0)),
		flr(y)+(h*8*(flip_y and 1 or 0)),
		0, flip_x and-1 or 1, flip_y and-1 or 1)
end

function api.sspr(sx, sy, sw, sh, dx, dy, dw, dh, flip_x, flip_y)
	dw=dw or sw
	dh=dh or sh
	-- FIXME: cache this quad
	local q=love.graphics.newQuad(sx, sy, sw, sh, pico8.spritesheet_data:getDimensions())
	--love.graphics.setShader(pico8.sprite_shader)
	love.graphics.draw(pico8.spritesheet_data, q,
		flr(dx)+(flip_x and dw or 0),
		flr(dy)+(flip_y and dh or 0),
		0, dw/sw*(flip_x and-1 or 1), dh/sh*(flip_y and-1 or 1))
	--love.graphics.setShader(pico8.draw_shader)

end

function api.rect(x0, y0, x1, y1, col)
	local prevCol = pico8.color
	if col then
		color(col)
	end
	local w, h=flr(x1-x0), flr(y1-y0)
	if w==0 or h==0 then
		love.graphics.rectangle("fill", flr(x0), flr(y0), w+1, h+1)
	else
		love.graphics.rectangle("line", flr(x0)+0.5, flr(y0)+0.5, w, h)
	end

	if prevCol then
		color(prevCol)
	end
end

function api.rectfill(x0, y0, x1, y1, col)
	local prevCol = pico8.color
	if col then
		color(col)
	end
	if x1<x0 then
		x0, x1=x1, x0
	end
	if y1<y0 then
		y0, y1=y1, y0
	end
	love.graphics.rectangle("fill", flr(x0), flr(y0), flr(x1-x0)+1, flr(y1-y0)+1)

	if prevCol then
		color(prevCol)
	end
end

function api.circ(ox, oy, r, col)
	local prevCol = pico8.color
	if col then
		color(col)
	end
	ox=flr(ox)+0.5
	oy=flr(oy)+0.5
	r=flr(r)
	local points={}
	local x=r
	local y=0
	local decisionOver2=1-x

	while y<=x do
		table.insert(points, {ox+x, oy+y})
		table.insert(points, {ox+y, oy+x})
		table.insert(points, {ox-x, oy+y})
		table.insert(points, {ox-y, oy+x})

		table.insert(points, {ox-x, oy-y})
		table.insert(points, {ox-y, oy-x})
		table.insert(points, {ox+x, oy-y})
		table.insert(points, {ox+y, oy-x})
		y=y+1
		if decisionOver2<0 then
			decisionOver2=decisionOver2+2*y+1
		else
			x=x-1
			decisionOver2=decisionOver2+2*(y-x)+1
		end
	end
	if #points>0 then
		love.graphics.points(points)
	end

	if prevCol then
		color(prevCol)
	end
end

function api.circfill(cx, cy, r, col)
	local prevCol = pico8.color
	if col then
		color(col)
	end
	cx=flr(cx)
	cy=flr(cy)
	r=flr(r)
	local x=r
	local y=0
	local err=1-r

	local lines={}

	while y<=x do
		_plot4points(lines, cx, cy, x, y)
		if err<0 then
			err=err+2*y+3
		else
			if x~=y then
				_plot4points(lines, cx, cy, y, x)
			end
			x=x-1
			err=err+2*(y-x)+3
		end
		y=y+1
	end
	if #lines>0 then
		for i=1, #lines do
			love.graphics.line(lines[i])
		end
	end

	if prevCol then
		color(prevCol)
	end
end

function api.line(x0, y0, x1, y1, col)
	local prevCol = pico8.color

	if col then
		color(col)
	end

	if x0~=x0 or y0~=y0 or x1~=x1 or y1~=y1 then
		warning("line has NaN value")
		return
	end

	x0=flr(x0)
	y0=flr(y0)
	x1=flr(x1)
	y1=flr(y1)

	if x0==x1 or y0==y1 then
		-- simple case draw a straight line
		love.graphics.rectangle("fill", x0, y0, x1-x0+1, y1-y0+1)
	else
		--this line is too fat, but it will do for now
		--TODO: redraw using points that isn't fat
		love.graphics.line(x0+0.5, y0+0.5, x1+0.5, y1+0.5)
		-- Final pixel not being reached?
		--love.graphics.points(x1+0.5, y1+0.5)
	end

	if prevCol then
		color(prevCol)
	end
end

function api.pal(c0, c1, p)

end

function api.palt(c, t)

end

function api.fillp(p)
	-- TODO: oh jeez
end

function api.map(cel_x, cel_y, sx, sy, cel_w, cel_h, bitmask)
	cel_x=flr(cel_x or 0)
	cel_y=flr(cel_y or 0)
	sx=flr(sx or 0)
	sy=flr(sy or 0)
	cel_w=flr(cel_w or 128)
	cel_h=flr(cel_h or 64)
	for y=0, cel_h-1 do
		if cel_y+y<64 and cel_y+y>=0 then
			for x=0, cel_w-1 do
				if cel_x+x<128 and cel_x+x>=0 then
					local v=pico8.map[flr(cel_y+y)][flr(cel_x+x)]
					if v~=0 then
						if bitmask==nil or bitmask==0 or bit.band(pico8.spriteflags[v], bitmask)~=0 then
							love.graphics.draw(pico8.spritesheet_data, pico8.quads[v], sx+8*x, sy+8*y)
						end
					end
				end
			end
		end
	end
end
api.mapdraw=api.map

function api.mget(x, y)
	x=flr(x or 0)
	y=flr(y or 0)
	if x>=0 and x<128 and y>=0 and y<64 then
		return pico8.map[y][x]
	end
	return 0
end

function api.mset(x, y, v)
	x=flr(x or 0)
	y=flr(y or 0)
	v=flr(v or 0)%256
	if x>=0 and x<128 and y>=0 and y<64 then
		pico8.map[y][x]=v
	end
end

function api.fget(n, f)
	if n==nil then return nil end
	if f~=nil then
		-- return just that bit as a boolean
		if not pico8.spriteflags[flr(n)] then
			warning(string.format('fget(%d, %d)', n, f))
			return false
		end
		return bit.band(pico8.spriteflags[flr(n)], bit.lshift(1, flr(f)))~=0
	end
	return pico8.spriteflags[flr(n)] or 0
end

function api.fset(n, f, v)
	-- fset n [f] v
	-- f is the flag index 0..7
	-- v is boolean
	if v==nil then
		v, f=f, nil
	end
	if f then
		-- set specific bit to v (true or false)
		if v then
			pico8.spriteflags[n]=bit.bor(pico8.spriteflags[n], bit.lshift(1, f))
		else
			pico8.spriteflags[n]=bit.band(pico8.spriteflags[n], bit.bnot(bit.lshift(1, f)))
		end
	else
		-- set bitfield to v (number)
		pico8.spriteflags[n]=v
	end
end

function api.sget(x, y)

end

function api.sset(x, y, c)

end

function api.music(n, fade_len, channel_mask)

end

function api.sfx(n, channel, offset)

end

function api.peek(addr)

end

function api.poke(addr, val)

end

function api.peek4(addr)

end

function api.poke4(addr, val)

end

function api.memcpy(dest_addr, source_addr, len)

end

function api.memset(dest_addr, val, len)

end

function api.reload(dest_addr, source_addr, len)
end

function api.cstore(dest_addr, source_addr, len)
end

function api.rnd(x)
	return math.random()*(x or 1)
end

function api.srand(seed)
	--math.randomseed(flr(seed*0x10000))
end

api.flr=math.floor
api.ceil=math.ceil

function api.sgn(x)
	return x<0 and-1 or 1
end

api.abs=math.abs

function api.min(a, b)
	if a==nil or b==nil then
		warning('min a or b are nil returning 0')
		return 0
	end
	if a<b then return a end
	return b
end

function api.max(a, b)
	if a==nil or b==nil then
		warning('max a or b are nil returning 0')
		return 0
	end
	if a>b then return a end
	return b
end

function api.mid(x, y, z)
	return (x<=y)and((y<=z)and y or((x<z)and z or x))or((x<=z)and x or((y<z)and z or y))
end

function api.cos(x)
	return math.cos((x or 0)*math.pi*2)
end

function api.sin(x)
	return-math.sin((x or 0)*math.pi*2)
end

api.sqrt=math.sqrt


function api.load(filename)
	_load(filename)
end

function api.save()

end

function api.run()
	_load()
end

function api.stop()
end

function api.reboot()
end

function api.shutdown()
end

function api.exit()
end

function api.info()
end

function api.export()
end

function api.import()
end

function api.help()
end

function api.time()
	return pico8.frames/30
end
--api.t=api.time

function api.login()
	return nil
end

function api.logout()
	return nil
end

function api.bbsreq()
	return nil
end

function api.scoresub()
	return nil, 0
end

function api.extcmd(x)
	-- TODO: Implement this?
end

function api.radio()
	return nil, 0
end

function api.btn(i, p)
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

function api.btnp(i, p)
	if i~=nil or p~=nil then
		p=p or 0
		if p<0 or p>1 then
			return false
		end
		local init=(pico8.fps/2-1)
		local v=pico8.keypressed.counter
		if pico8.keypressed[p][i] and (v==init or v==1) then
			return true
		end
		return false
	else
		local init=(pico8.fps/2-1)
		local v=pico8.keypressed.counter
		if not (v==init or v==1) then
			return 0
		end
		local bits=0
		for i=0, 5 do
			bits=bits+(pico8.keypressed[0][i] and 2^i or 0)
			bits=bits+(pico8.keypressed[1][i] and 2^(i+8) or 0)
		end
		return bits
	end
end


-- The functions below are normally attached to the program code, but are here for simplicity
function api.all(a)
	if a==nil or #a==0 then
		return function() end
	end
	local i, li=1
	return function()
		if (a[i]==li) then i=i+1 end
		while(a[i]==nil and i<=#a) do i=i+1 end
		li=a[i]
		return a[i]
	end
end

function api.foreach(a, f)
	for v in api.all(a) do
		f(v)
	end
end

function api.count(a)
	local count=0
	for i=1, #a do
		if a[i]~=nil then count=count+1 end
	end
	return count
end

function api.add(a, v)
	if a==nil then return end
	a[#a+1]=v
end

function api.del(a, dv)
	if a==nil then return end
	for i=1, #a do
		if a[i]==dv then
			table.remove(a, i)
			return
		end
	end
end

return api
