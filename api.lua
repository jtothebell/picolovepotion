local flr=math.floor

local resX = flr(pico8.resolution[1])
local resY = flr(pico8.resolution[2])
local pixelCount = resX * resY

--these buffers and counts will be reused instead of re-initializing on every draw call
local xBuf = {}
local yBuf = {}
local cBuf = {}

local function preFillBuffer(buffer, count)
	local i=1
	for i=1, count do
		buffer[i] = 0
	end
end

local function clipContains(clip, x, y)
	return clip[1] <= x and 
		x < clip[3] and 
		clip[2] <= y and 
		y < clip[4]
end

local function setSeparatedPointsOnScreenBuffer(xvalues, yvalues, colorIdx)
	local lp8 = pico8
	local clip = lp8.clip
	local camera_x = lp8.camera_x
	local camera_y = lp8.camera_y
	local screen_buffer = lp8.screen_buffer
	local draw_palette = lp8.draw_palette
	local globalColor = lp8.color
	local color = colorIdx or globalColor
	color = draw_palette[color]
	local x = 0
	local y = 0
	local index = 1

	if xvalues and yvalues then
		for i=1, #xvalues do
			x = xvalues[i] - camera_x
			y = yvalues[i] - camera_y
			if (x >= 0 and x < 128 and y >= 0 and y < 128) and (clip == nil or clipContains(clip, x, y)) then
				index = flr(y)*resY + flr(x) + 1
				
				
				if colvalues ~= nil then
					color = draw_palette[ colvalues[i] ]
				end
				screen_buffer[index] = color
			end
		end
	end
end

local function moveXAndYBufToScreen(count, colorIdx)
	local lp8 = pico8
	local clip = lp8.clip
	local camera_x = lp8.camera_x
	local camera_y = lp8.camera_y
	local screen_buffer = lp8.screen_buffer
	local draw_palette = lp8.draw_palette
	local globalColor = lp8.color
	local color = colorIdx or globalColor
	color = draw_palette[color]
	local x = 0
	local y = 0
	local index = 1

	for i=1, count do
		x = xBuf[i] - camera_x
		y = yBuf[i] - camera_y
		if (x >= 0 and x < 128 and y >= 0 and y < 128) and (clip == nil or clipContains(clip, x, y)) then
			index = flr(y)*resY + flr(x) + 1
			
			
			if colvalues ~= nil then
				color = draw_palette[ colvalues[i] ]
			end
			screen_buffer[index] = color
		end
	end
end

local function setSeparatedSpritePointsOnScreenBuffer(xvalues, yvalues, colvalues)
	local lp8 = pico8
	local clip = lp8.clip
	local camera_x = lp8.camera_x
	local camera_y = lp8.camera_y
	local screen_buffer = lp8.screen_buffer
	local draw_palette = lp8.draw_palette
	local x = 0
	local y = 0
	local index = 1


	if xvalues and yvalues and colvalues then
		for i=1, #xvalues do
			x = xvalues[i] - camera_x
			y = yvalues[i] - camera_y
			if (x >= 0 and x < 128 and y >= 0 and y < 128) and (clip == nil or clipContains(clip, x, y)) then
				index = flr(y)*resY + flr(x) + 1

				color = draw_palette[ colvalues[i] ]

				screen_buffer[index] = color
			end
		end
	end
end

local function moveXAndYAndCBufToScreen(count)
	local lp8 = pico8
	local clip = lp8.clip
	local camera_x = lp8.camera_x
	local camera_y = lp8.camera_y
	local screen_buffer = lp8.screen_buffer
	local draw_palette = lp8.draw_palette
	local x = 0
	local y = 0
	local index = 1

	for i=1, count do
		x = xBuf[i] - camera_x
		y = yBuf[i] - camera_y
		if (x >= 0 and x < 128 and y >= 0 and y < 128) and (clip == nil or clipContains(clip, x, y)) then
			index = flr(y)*resY + flr(x) + 1
			color = draw_palette[ cBuf[i] ]
			screen_buffer[index] = color
		end
	end
end



local function color(c)
	c=flr(c or 0)%16
	pico8.color=c
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

local api={
	fontSpriteTable = require("fontSpriteTable")
}

function api._init()
	--Fill in these buffers with lots of dummy data do we don't waste time reinitializing
	preFillBuffer(xBuf, pixelCount)
	preFillBuffer(yBuf, pixelCount)
	preFillBuffer(cBuf, pixelCount)
end

function api.flip()
	flip_screen()
	love.timer.sleep(1/pico8.fps)
end

function api.camera(x, y)
	if x~=nil then
		pico8.camera_x=flr(x)
		pico8.camera_y=flr(y)
	else
		pico8.camera_x=0
		pico8.camera_y=0
	end
	--restore_camera()
end

function api.clip(x, y, w, h)
	if x and y and w and h then
		pico8.clip={x, y, x + w, x + h}
	else
		pico8.clip=nil
	end
end

function api.cls(c)
	c = tonumber(c) or 0
	if c == nil then
		c = 0
	end

	pico8.clip=nil
	--size of pico 8 screen
	--love.graphics.setScissor()
	--TODO clear the color passed
	local color = pico8.palette[c + 1]

	local pixelCount = pico8.resolution[1]*pico8.resolution[2]
	for i=1, pixelCount do
		pico8.screen_buffer[i] = c
	end
	--love.graphics.clear(color[1], color[2], color[3], 1)
	--pico love uses the background color for clear. This doesn't match love behavior
	--love.graphics.setBackgroundColor(color[1], color[2], color[3])
	--love.graphics.clear()
	pico8.cursor={0, 0}

end

function api.folder()
end

function api.ls()
end
api.dir=api.ls

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

function api.pset(x, y, col)
	if col then
		color(col)
	end

	--[[
	setSeparatedPointsOnScreenBuffer({flr(x)}, {flr(y)}, col)
	]]

	xBuf[1] = flr(x)
	yBuf[1] = flr(y)

	moveXAndYBufToScreen(1, col)

end


function api.pget(x, y)
	x=x-pico8.camera_x
	y=y-pico8.camera_y

	local index = y*pico8.resolution[2] + x + 1
	return pico8.screen_buffer[index]
	--TODO: ruh roh :( need imageData support from LovePotion, or huge refactor
	--[[
	if x>=0 and x<pico8.resolution[1] and y>=0 and y<pico8.resolution[2] then
		love.graphics.setCanvas()
		local c=pico8.screen:newImageData():getPixel(flr(x), flr(y))*15
		love.graphics.setCanvas(pico8.screen)
		return c
	end
	warning(string.format("pget out of screen %d, %d", x, y))
	]]
	--return 0
end

function api.color(c)
	color(c)
end

local function getPrintArrays(str, x, y)
	xs = {}
	ys = {}

	if x and y then
		pico8.cursor[1]=flr(tonumber(x) or 0)
		pico8.cursor[2]=flr(tonumber(y) or 0)
	end

	local pointCount = 0

	--local inspect = require 'inspect'

	
	local str=tostring(str):gsub("[%z\1-\9\11-\31\154-\255]", " "):gsub("[\128-\153]", "\194%1").."\n"
	local size=0

	for line in str:gmatch("(.-)\n") do
		local xAdd = 0
		for i = 1, #tostring(line) do
			local character = string.sub(line, i, i)
			--print("char: " .. character)
			local charTable = api.fontSpriteTable[character]

			if charTable ~= nil then
				local startX = pico8.cursor[1] + xAdd
				local startY =  pico8.cursor[2] + size
				local tableX = 0
				local tableY = 0

				for tableY = 1, #charTable do
					for tableX = 1, #charTable[tableY] do
						local val = charTable[tableY][tableX]

						if val > 0 then
							pointCount = pointCount + 1
							local x = startX + tableX - 1
							local y = startY + tableY - 1
							--print(x .. ', ' .. y)
							xs[pointCount] = x
							ys[pointCount] = y
						end
					end
				end
			end

        	xAdd = xAdd + 4
    	end
		size=size+6
	end

	if not x and not y then
		if pico8.cursor[2]+size>122 then
			
		else
			pico8.cursor[2]=pico8.cursor[2]+size
		end
	end

	return xs, ys
end

local function getPrintPoints(str, x, y)

	if x and y then
		pico8.cursor[1]=flr(tonumber(x) or 0)
		pico8.cursor[2]=flr(tonumber(y) or 0)
	end

	local points = {}
	local pointCount = 0

	--local inspect = require 'inspect'

	
	local str=tostring(str):gsub("[%z\1-\9\11-\31\154-\255]", " "):gsub("[\128-\153]", "\194%1").."\n"
	local size=0

	for line in str:gmatch("(.-)\n") do
		local xAdd = 0
		for i = 1, #tostring(line) do
			local character = string.sub(line, i, i)
			--print("char: " .. character)
			local charTable = api.fontSpriteTable[character]

			if charTable ~= nil then
				local startX = pico8.cursor[1] + xAdd
				local startY =  pico8.cursor[2] + size
				local tableX = 0
				local tableY = 0

				for tableY = 1, #charTable do
					for tableX = 1, #charTable[tableY] do
						local val = charTable[tableY][tableX]

						if val > 0 then
							pointCount = pointCount + 1
							local x = startX + tableX - 1
							local y = startY + tableY - 1
							--print(x .. ', ' .. y)
							points[pointCount] = {x, y}
						end
					end
				end
			end

        	xAdd = xAdd + 4
    	end
		size=size+6
	end

	if not x and not y then
		if pico8.cursor[2]+size>122 then
			
		else
			pico8.cursor[2]=pico8.cursor[2]+size
		end
	end

	return points

end

function api.print(str, x, y, col)
	if col then
		color(col)
	end

	local xs, ys = getPrintArrays(str, x, y)

	setSeparatedPointsOnScreenBuffer(xs, ys, col)

end

api.printh=print

function api.cursor(x, y)
	pico8.cursor={x or 0, y or 0}
end

function api.tonum(val)
	return tonumber(val) -- not a direct assignment to prevent usage of the radix argument
end

function api.tostr(val, hex)
	local kind=type(val)
	if kind == "string" then
		return val
	elseif kind == "number" then
		if hex then
			val=val*0x10000
			local part1=bit.rshift(bit.band(val, 0xFFFF0000), 16)
			local part2=bit.band(val, 0xFFFF)
			return string.format("0x%04x.%04x", part1, part2)
		else
			return tostring(val)
		end
	elseif kind == "boolean" then
		return tostring(val)
	else
		return "[" .. kind .. "]"
	end
end

local function getSprArrays(n, x, y, w, h, flip_x, flip_y)

	n=flr(n)
	w=w or 1
	h=h or 1


	local pixelW = flr(8 * w)
	local pixelH = flr(8 * h)

	local sx = flr(n%16)*8;
	local sy = flr(n/16)*8

	xs = {}
	ys = {}
	colors = {}
	local pixelIdx = 1

	local ssTable = pico8.spritesheet_table

	for yInc=0, pixelH - 1 do
		for xInc=0, pixelW - 1 do
			local ssX = xInc
			if flip_x then
				ssX = pixelW - xInc - 1
			end

			local ssY = yInc
			if flip_y then
				ssY = pixelH - yInc - 1
			end

			local color = ssTable[sx + ssX][sy + ssY]
			--todo check transparency here
			if color > 0 then
				xs[pixelIdx] = x + xInc
				ys[pixelIdx] = y + yInc
				colors[pixelIdx] = color	
				pixelIdx = pixelIdx + 1
			end
		end
	end

	return xs, ys, colors
end

function api.spr(n, x, y, w, h, flip_x, flip_y)
	local xs, ys, colors = getSprArrays(n, x, y, w, h, flip_x, flip_y)

	setSeparatedSpritePointsOnScreenBuffer(xs, ys, colors)
end

--s: sprite sheet coords, d: screen coords
local function getSsprArrays(sx, sy, sw, sh, dx, dy, dw, dh, flip_x, flip_y)
    dw=dw or sw
    dh=dh or sh
	local xs = {}
	local ys = {}
	local colors = {}
	local widthFactor = sw / dw
	local heightFactor = sh / dh

    local pixelIdx = 1
    local ssTable = pico8.spritesheet_table
    for yInc=0, dh - 1 do
		for xInc=0, dw - 1 do
			local ssDeltaX = flr(xInc * widthFactor)
			if flip_x then ssDeltaX = sw - ssDeltaX end
			local ssDeltaY = flr(yInc * heightFactor)
			if flip_y then ssDeltaY = sh - ssDeltaY end

            local color = ssTable[sx + ssDeltaX][sy + ssDeltaY]
            if color > 0 then
				xs[pixelIdx] = dx + xInc
				ys[pixelIdx] = dy + yInc
				colors[pixelIdx] =  color
                pixelIdx = pixelIdx + 1
            end
        end
    end
    return xs, ys, colors
end

function api.sspr(sx, sy, sw, sh, dx, dy, dw, dh, flip_x, flip_y)
	local xs, ys, colors = getSsprArrays(sx, sy, sw, sh, dx, dy, dw, dh, flip_x, flip_y)

	setSeparatedSpritePointsOnScreenBuffer(xs, ys, colors)
end

local function getRectXAndYArrays(x0, y0, x1, y1)
	local w, h=flr(x1-x0), flr(y1-y0)

	local xs = {}
	local ys = {}
	local pointCount = 0

	for i = 1, w + 1 do
		local index = pointCount + 1
		xs[index] = x0 + (i - 1)
		ys[index] = y0
		xs[index + 1] = x0 + (i - 1)
		ys[index + 1] = y1
		pointCount = pointCount + 2
	end

	for i = 1, h + 1 do
		local index = pointCount + 1
		xs[index] = x0
		ys[index] = y0 + (i - 1)
		xs[index + 1] = x1
		ys[index + 1] = y0 + (i - 1)
		pointCount = pointCount + 2
	end

	return xs, ys
end

function api.rect(x0, y0, x1, y1, col)
	if col then
		color(col)
	end

	local xs, ys = getRectXAndYArrays(x0, y0, x1, y1)

	setSeparatedPointsOnScreenBuffer(xs, ys, col)

end

local function populateBufsForRectFill(x0, y0, x1, y1)
	if x1<x0 then
		x0, x1=x1, x0
	end
	if y1<y0 then
		y0, y1=y1, y0
	end

	--love.graphics.rectangle("fill", flr(x0), flr(y0), flr(x1-x0)+1, flr(y1-y0)+1)

	x0 = flr(x0)
	y0 = flr(y0)
	local w, h=flr(x1-x0), flr(y1-y0)

	local pointCount = 0

	for i = 0, w do
		for j = 0, h  do
			pointCount = pointCount + 1
			xBuf[pointCount] = x0 + i
			yBuf[pointCount] = y0 + j		
		end
	end

	return pointCount
end

local function getRectFillXAndYArrays(x0, y0, x1, y1)
	if x1<x0 then
		x0, x1=x1, x0
	end
	if y1<y0 then
		y0, y1=y1, y0
	end

	--love.graphics.rectangle("fill", flr(x0), flr(y0), flr(x1-x0)+1, flr(y1-y0)+1)

	x0 = flr(x0)
	y0 = flr(y0)
	local w, h=flr(x1-x0), flr(y1-y0)

	local xs = {}
	local ys = {}
	local pointCount = 0

	for i = 0, w do
		for j = 0, h  do
			pointCount = pointCount + 1
			xs[pointCount] = x0 + i
			ys[pointCount] = y0 + j		
		end
	end

	return xs, ys
end

function api.rectfill(x0, y0, x1, y1, col)
	prof.push("rectfill")
	if col then
		color(col)
	end

	--[[
	local xs, ys = getRectFillXAndYArrays(x0, y0, x1, y1)

	setSeparatedPointsOnScreenBuffer(xs, ys, col)
	]]

	
	local count = populateBufsForRectFill(x0, y0, x1, y1)

	moveXAndYBufToScreen(count, col)
	

	prof.pop("rectfill")
end

local function getCircXAndYArrays(ox, oy, r)
	ox=flr(ox)--+0.5
	oy=flr(oy)--+0.5
	r=flr(r)
	local xs={}
	local ys={}
	local pointCount = 0
	local x=r
	local y=0
	local decisionOver2=1-x

	while y<=x do
		--table.insert(points, {ox+x, oy+y})
		pointCount = pointCount + 1
		xs[pointCount] = ox + x
		ys[pointCount] = oy + y
		--table.insert(points, {ox+y, oy+x})
		pointCount = pointCount + 1
		xs[pointCount] = ox + y
		ys[pointCount] = oy + x
		--table.insert(points, {ox-x, oy+y})
		pointCount = pointCount + 1
		xs[pointCount] = ox - x
		ys[pointCount] = oy + y
		--table.insert(points, {ox-y, oy+x})
		pointCount = pointCount + 1
		xs[pointCount] = ox - y
		ys[pointCount] = oy + x
		

		--table.insert(points, {ox-x, oy-y})
		pointCount = pointCount + 1
		xs[pointCount] = ox - x
		ys[pointCount] = oy - y
		--table.insert(points, {ox-y, oy-x})
		pointCount = pointCount + 1
		xs[pointCount] = ox - y
		ys[pointCount] = oy - x
		--table.insert(points, {ox+x, oy-y})
		pointCount = pointCount + 1
		xs[pointCount] = ox + x
		ys[pointCount] = oy - y
		--table.insert(points, {ox+y, oy-x})
		pointCount = pointCount + 1
		xs[pointCount] = ox + y
		ys[pointCount] = oy - x
		y=y+1
		if decisionOver2<0 then
			decisionOver2=decisionOver2+2*y+1
		else
			x=x-1
			decisionOver2=decisionOver2+2*(y-x)+1
		end
	end

	return xs, ys
end

function api.circ(ox, oy, r, col)
	if col then
		color(col)
	end

	local xs, ys = getCircXAndYArrays(ox, oy, r)

	setSeparatedPointsOnScreenBuffer(xs, ys, col)

end

local function getLineXAndYArrays(x0, y0, x1, y1)
	if x0~=x0 or y0~=y0 or x1~=x1 or y1~=y1 then
		warning("line has NaN value")
		return
	end

	x0=flr(x0)
	y0=flr(y0)
	x1=flr(x1)
	y1=flr(y1)

	local xmin = api.min(x0, x1)
	local xmax = api.max(x0, x1)
	
	local ymin = api.min(y0, y1)
	local ymax = api.max(y0, y1)

	local rise = ymax - ymin
	local run = xmax - xmin

	local ceil = math.ceil

	local xs = {}
	local ys = {}
	if run == 0 then
		--vertical line
		for i = 1, rise + 1 do
			xs[i] = xmin
			ys[i] = ymin + (i - 1)
		end
	else
		local slope = rise / run
		if slope >= 1 then
			for i = 1, rise + 1 do
				xs[i] = xmin + ceil((i - 1) / slope)
				ys[i] = ymin + (i - 1)
			end
		else
			for i = 1, run + 1 do
				xs[i] = xmin + (i - 1)
				ys[i] = ymin + ceil((i - 1) * slope)
			end

		end
	end

	return xs, ys
end

local function getCircFillXAndYArrays(cx, cy, r)
	cx=flr(cx)
	cy=flr(cy)
	r=flr(r)
	local x=r
	local y=0
	local err=1-r

	local lines={}
	local xs = {}
	local ys = {}

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

	local pointCount = 0
	for i=1, #lines do
		local circLineXs, circLineYs = getLineXAndYArrays(lines[i][1], lines[i][2], lines[i][3], lines[i][4])
		for j=1, #circLineXs do
			pointCount = pointCount + 1
			xs[pointCount] = circLineXs[j]
			ys[pointCount] = circLineYs[j]
		end
	end

	return xs, ys
end

function api.circfill(cx, cy, r, col)
	if col then
		color(col)
	end

	local xs, ys = getCircFillXAndYArrays(cx, cy, r)

	setSeparatedPointsOnScreenBuffer(xs, ys, col)

end


function api.line(x0, y0, x1, y1, col)
	if col then
		color(col)
	end

	local xs, ys = getLineXAndYArrays(x0, y0, x1, y1)

	setSeparatedPointsOnScreenBuffer(xs, ys, col)
end



function api.pal(c0, c1, p)
	if c0==nil then
		local __palette_modified=false
		local __display_modified=false
		local __alpha_modified=false
		for i=0, 15 do
			if pico8.draw_palette[i]~=i then
				pico8.draw_palette[i]=i
				__palette_modified=true
			end
			if pico8.display_palette[i]~=pico8.palette[i+1] then
				pico8.display_palette[i]=pico8.palette[i+1]
				__display_modified=true
			end
			local alpha=i==0 and 0 or 1
			if pico8.pal_transparent[i]~=alpha then
				pico8.pal_transparent[i]=alpha
				__alpha_modified=true
			end
		end
		if __palette_modified or __alpha_modified then
			--refreshSpritesheetCanvas()
		end
		if __display_modified then
			--not yet supported
		end
	elseif p==1 and c1~=nil then
		c0=flr(c0)%16
		c1=flr(c1)%16
		if pico8.draw_palette[c0]~=pico8.palette[c1+1] then
			pico8.display_palette[c0]=pico8.palette[c1+1]
			--not sure there is a good way to do this one without imageData or a shader :|
		end
	elseif c1~=nil then
		c0=flr(c0)%16
		c1=flr(c1)%16
		if pico8.draw_palette[c0]~=c1 then
			pico8.draw_palette[c0]=c1
			
		end
		--refreshSpritesheetCanvas()
	end
end

function api.palt(c, t)
	if c==nil then
		for i=0, 15 do
			pico8.pal_transparent[i]=i==0 and 0 or 1
		end
	else
		c=flr(c)%16
		pico8.pal_transparent[c]=t and 0 or 1
	end
	--refreshSpritesheetCanvas()
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
	bitmask=flr(bitmask or 0)
	for y=0, cel_h-1 do
		if cel_y+y<64 and cel_y+y>=0 then
			for x=0, cel_w-1 do
				if cel_x+x<128 and cel_x+x>=0 then
					local v=pico8.map[flr(cel_y+y)][flr(cel_x+x)]
					if v~=0 then
						if bitmask==0 or bit.band(pico8.spriteflags[v], bitmask)~=0 then
							local xPos = sx + (8*x) - pico8.camera_x;
							local yPos = sy + (8*y) - pico8.camera_y;
							--limit drawing to what is on screen
							if xPos > -9 and xPos < 128 and yPos > -9 and yPos < 128 then
								local xs, ys, colors = getSprArrays(v, sx + (8*x), sy + (8*y))

								setSeparatedSpritePointsOnScreenBuffer(xs, ys, colors)
							end
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
	-- return the color from the spritesheet
	x=flr(x)
	y=flr(y)
	if x>=0 and x<128 and y>=0 and y<128 then
		local c=pico8.spritesheet_table[x][y]
		return c
	end
	return 0

end

function api.sset(x, y, c)
	x=flr(x)
	y=flr(y)
	c=flr(c or 0)%16
	if x>=0 and x<128 and y>=0 and y<128 then
		pico8.spritesheet_table[x][y] = c
		
		--TODO: test this
		--bust the sprite sheet cache, it is now inaccurate
		--for k in pairs (pico8.spritesheet_cache) do
		--	pico8.spritesheet_cache[k] = nil
		--end
	end

end

function api.music(n, fade_len, channel_mask)

end

function api.sfx(n, channel, offset)

end

function api.peek(addr)
	return 0
end

function api.poke(addr, val)

end

function api.peek4(addr)
	return 0
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

function api.atan2(x, y)
	return (0.75 + math.atan2(x,y) / (math.pi * 2)) % 1.0
end

function api.band(x, y)
	return bit.band(x*0x10000, y*0x10000)/0x10000
end

function api.bor(x, y)
	return bit.bor(x*0x10000, y*0x10000)/0x10000
end

function api.bxor(x, y)
	return bit.bxor(x*0x10000, y*0x10000)/0x10000
end

function api.bnot(x)
	return bit.bnot(x*0x10000)/0x10000
end

function api.shl(x, y)
	return bit.lshift(x*0x10000, y)/0x10000
end

function api.shr(x, y)
	return bit.arshift(x*0x10000, y)/0x10000
end

function api.lshr(x, y)
	return bit.rshift(x*0x10000, y)/0x10000
end

function api.rotl(x, y)
	return bit.rol(x*0x10000, y)/0x10000
end

function api.rotr(x, y)
	return bit.ror(x*0x10000, y)/0x10000
end

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

function api.cartdata(id)
end

function api.dget(index)
	index=flr(index)
	if index<0 or index>63 then
		warning('cartdata index out of range')
		return
	end
	return pico8.cartdata[index]
end

function api.dset(index, value)
	index=flr(index)
	if index<0 or index>63 then
		warning('cartdata index out of range')
		return
	end
	pico8.cartdata[index]=value
end

local tfield={[0]="year", "month", "day", "hour", "min", "sec"}
function api.stat(x)
	if x == 4 then
		return pico8.clipboard
	elseif x == 7 then
		return pico8.fps
	elseif x == 8 then
		return pico8.fps
	elseif x == 9 then
		return love.timer.getFPS()
	elseif x >= 16 and x <= 23 then
		local ch=pico8.audio_channels[x%4]
		if not ch.sfx then
			return -1
		elseif x < 20 then
			return ch.sfx
		else
			return flr(ch.offset)
		end
	elseif x == 30 then
		return #pico8.kbdbuffer ~= 0
	elseif x == 31 then
		return (table.remove(pico8.kbdbuffer, 1) or "")
	elseif x == 32 then
		return getMouseX()
	elseif x == 33 then
		return getMouseY()
	elseif x == 34 then
		local btns=0
		for i=0, 2 do
			if love.mouse.isDown(i+1) then
				btns=bit.bor(btns, bit.lshift(1, i))
			end
		end
		return btns
	elseif x == 36 then
		return pico8.mwheel
	elseif (x >= 80 and x <= 85) or (x >= 90 and x <= 95) then
		local tinfo
		if x < 90 then
			tinfo = os.date("!*t")
		else
			tinfo = os.date("*t")
		end
		return tinfo[tfield[x%10]]
	elseif x == 100 then
		return nil -- TODO: breadcrumb not supported
	end
	return 0
end

function api.holdframe()
	-- TODO: Implement this
end

function api.menuitem()
end

api.sub=string.sub
api.pairs=pairs
api.type=type
api.assert=assert
api.setmetatable=setmetatable
api.getmetatable=getmetatable
api.cocreate=coroutine.create
api.coresume=coroutine.resume
api.yield=coroutine.yield
api.costatus=coroutine.status
api.trace=debug.traceback

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
