pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _draw()
	cls(14)
	--45 degree
	line(10, 10, 20, 20, 2)
	line(10, 10, 20, 20, 2)
	
	--horizontal
	line(10, 10, 20, 10, 3)
	
	line(10, 20, 20, 25, 4)
	
	--vertical
	line(10, 30, 10, 40, 5)
	
	rect(60, 10, 60, 20, 6)
	
	rect(60, 22, 70, 32, 8)
	
	rectfill(60, 34, 70, 44, 9)
end
