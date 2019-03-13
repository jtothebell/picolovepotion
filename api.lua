local flr=math.floor

-- TODO: Remove this
--[[
local scrblitMesh=love.graphics.newMesh(128, "points")
scrblitMesh:setAttributeEnabled("VertexColor", true)
]]-

local function color(c)
	c=flr(c or 0)%16
	pico8.color=c
	setColor(c)
end

local function warning(msg)
	--log(debug.traceback("WARNING: "..msg, 3))
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

end

function api.pget(x, y)

end

function api.color(c)
	color(c)
end

function api.print(str, x, y, col)

end

api.printh=print

function api.cursor(x, y)

end

function api.tonum(val)

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
			log('warning: sprite '..n..' is missing')
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
		log('missing quad', n)
	end
	love.graphics.draw(pico8.spritesheet, q,
		flr(x)+(w*8*(flip_x and 1 or 0)),
		flr(y)+(h*8*(flip_y and 1 or 0)),
		0, flip_x and-1 or 1, flip_y and-1 or 1)
	--love.graphics.setShader(pico8.draw_shader)
end

function api.sspr(sx, sy, sw, sh, dx, dy, dw, dh, flip_x, flip_y)
	dw=dw or sw
	dh=dh or sh
	-- FIXME: cache this quad
	local q=love.graphics.newQuad(sx, sy, sw, sh, pico8.spritesheet:getDimensions())
	love.graphics.setShader(pico8.sprite_shader)
	love.graphics.draw(pico8.spritesheet, q,
		flr(dx)+(flip_x and dw or 0),
		flr(dy)+(flip_y and dh or 0),
		0, dw/sw*(flip_x and-1 or 1), dh/sh*(flip_y and-1 or 1))
	love.graphics.setShader(pico8.draw_shader)
end

function api.rect(x0, y0, x1, y1, col)
	if col then
		color(col)
	end
	local w, h=flr(x1-x0), flr(y1-y0)
	if w==0 or h==0 then
		love.graphics.rectangle("fill", flr(x0), flr(y0), w+1, h+1)
	else
		love.graphics.rectangle("line", flr(x0)+0.5, flr(y0)+0.5, w, h)
	end
end

function api.rectfill(x0, y0, x1, y1, col)
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
end

function api.circ(ox, oy, r, col)

end

function api.circfill(cx, cy, r, col)

end

function api.line(x0, y0, x1, y1, col)
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
		love.graphics.line(x0+0.5, y0+0.5, x1+0.5, y1+0.5)
		-- Final pixel not being reached?
		love.graphics.points(x1+0.5, y1+0.5)
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

end
api.mapdraw=api.map

function api.mget(x, y)

end

function api.mset(x, y, v)

end

function api.fget(n, f)

end

function api.fset(n, f, v)

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
	math.randomseed(flr(seed*0x10000))
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
api.t=api.time

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
