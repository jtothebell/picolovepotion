pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
t=0
function _init()
	ship = {
		x=60,
		y=100,
		sp=7,
		llaserx=-1,
		rlaserx=6,
		leftshot=true,
		box = {x1=0, y1=0, x2=7, y2=7}
	}

	lasers = {}


	enemies = {}
	add(enemies, rndmenemy())

	explosions = {}
	
 	
	stars = {}
 	for i=1,32 do
		add(stars,{
			x=rnd(128),
			y=rnd(128),
			s=rnd(2)+1
		})
	end 
end

function rndmenemy()
	local e = {
		sp=8,
		x= 32 + rnd(64),
		y=-32,
		dx= rnd(4) - 2,
		dy= 2,
		llaserx=2,
		rlaserx=4,
		leftshot=true,
		countdown=rnd(30) + 10,
		box = {x1=0, y1=1, x2=7, y2=5}
	}
	return e
end


function abs_box(s)
	local box = {}
	box.x1 = s.box.x1 + s.x
	box.y1 = s.box.y1 + s.y
	box.x2 = s.box.x2 + s.x
	box.y2 = s.box.y2 + s.y
	return box
end

function coll(a,b)
	-- todo
	local box_a = abs_box(a)
	local box_b = abs_box(b)

	if box_a.x1 > box_b.x2 or
    	box_a.y1 > box_b.y2 or
    	box_b.x1 > box_a.x2 or
    	box_b.y1 > box_a.y2 then
    	return false
	end
	
	return true 
end

function explode(x,y)
	add(explosions,{x=x,y=y,t=0})
end

function fire(parent)
	local enemy = true
	if parent == ship then
		enemy = false
	end

	local offset = parent.rlaserx
	if parent.leftshot then
		offset = parent.llaserx
	end

	local dy = -3;
	local yoffset = -2;
	if enemy then
		dy = 3
		yoffset = 6
	end

	local l = {
		sp = 16,
		x = parent.x + offset,
		y = parent.y + yoffset,
		spw = .5,
		sph = .5,
		dx = 0,
		dy = dy,
		box = {x1=1,y1=0,x2=1,y2=4}
	}
	parent.leftshot = not parent.leftshot
	add(lasers, l)
end

function _draw()
	cls()
	
	for st in all(stars) do
		pset(st.x,st.y,6)
	end


	spr(ship.sp, ship.x, ship.y)

	for ex in all(explosions) do
		rect(ex.x, ex.y, ex.x + ex.t/2, ex.y + ex.t/2, 8+ex.t%3)
	end
	
	for l in all(lasers) do
		spr(l.sp, l.x, l.y, l.spw, l.sph)
	end
	
	for e in all(enemies) do
		spr(e.sp, e.x, e.y)
	end
	
end

function _update()
	t=t+1

	if t % 15 == 0 then
		add(enemies, rndmenemy())
	end

	for st in all(stars) do
		st.y += st.s
		if st.y >= 128 then
			st.y = 0
			st.x=rnd(128)
		end
	end

	for ex in all(explosions) do
		ex.t+=1
		if ex.t == 13 then
			del(explosions, ex)
		end
	end

	for e in all(enemies) do
  		e.x = e.x + e.dx
  		e.y = e.y + e.dy

		if e.x < -8 or e.x > 136 or
		e.y < -50 or e.y > 136 then
			del(enemies, e)
		end

		if coll(ship, e) then
			explode(ship.x,ship.y)
			explode(e.x, e.y)
		end

		e.countdown = e.countdown - 1
		if e.countdown <= 0 then
			fire(e)
			e.countdown = rnd(30) + 10
		end
 	end

	for l in all(lasers) do
		l.x += l.dx
		l.y += l.dy

		if l.x < 0 or l.x > 128 or l.y < 0 or l.y > 128 then
			del(lasers, l)
		else
			local hit = false
			for e in all (enemies) do
				if coll(l, e) then
					del(enemies, e)
					del(lasers, l)
					explode(e.x,e.y)
					hit = true
				end
			end

			if hit == false and coll(l, ship) then
				del(lasers, l)
				explode(ship.x,ship.y)
			end
		end
	end

	if btn(0) then ship.x -=2 end
	if btn(1) then ship.x +=2 end
	if btn(2) then ship.y -=2 end
	if btn(3) then ship.y +=2 end
	if btnp(4) then fire(ship) end
end
__gfx__
e0000000000000000000000000000000000000000000000000000000000660005000000500000000000000000000000000000000000000000000000000000000
00000000000000067000000000000000000000000500000000000050800660085005500500000000000000000000000000000000000000000000000000000000
00700700000000066000000000000000000000000500000000000050600550065055550500000000000000000000000000000000000000000000000000000000
00077000000000066000000000000000000000000500000000000050600550065550055500000000000000000000000000000000000000000000000000000000
00077000000000066000000000000000000000000500000550000050600660065555555500000000000000000000000000000000000000000000000000000000
00700700000000666700000000000000000000000500005555000050666cc66650b55b0500000000000000000000000000000000000000000000000000000000
00000000008000666600080000000000000000000550055555500050666cc6665006600500000000000000000000000000000000000000000000000000000000
0000000080d00065d6000d0800000000000000000555555555555550000660005000000500000000000000000000000000000000000000000000000000000000
0b00080060d0006556000d0600000000000000000550055665500550000000000000000000000000000000000000000000000000000000000000000000000000
0b00080060ddd065560ddd0600000000000000000500005555000050000000000000000000000000000000000000000000000000000000000000000000000000
0b000800600ddd6556ddd00600000000000000000500008558000050000000000000000000000000000000000000000000000000000000000000000000000000
0b000800666666666666666600000000000000000500000000000050000000000000000000000000000000000000000000000000000000000000000000000000
00000000666866666666666600000000000000000500000000000050000000000000000000000000000000000000000000000000000000000000000000000000
000000000666666cc666666000000000000000000500000000000050000000000000000000000000000000000000000000000000000000000000000000000000
000000000006666cc666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
