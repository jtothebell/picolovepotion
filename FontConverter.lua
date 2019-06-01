function writeFontToText()

    local data=love.image.newImageData("font32bit.png")

	local glyphs=""
	for i=32, 127 do
		glyphs=glyphs..string.char(i)
	end
	for i=128, 153 do
		glyphs=glyphs..string.char(194, i)
	end
	pico8.glyphs = glyphs

	local width,height = data:getDimensions()
    
    local x = 0
	local y = 0
	local charWidth = 3

	local fontTable = {}

	for i = 1, #glyphs do
		local char = string.sub(glyphs, i, i)
		fontTable[char] = {}
		local charX = (i - 1) * (charWidth + 1) + 1
		for y=0, height - 1 do
			fontTable[char][y + 1] = {}
			for x=0, charWidth - 1 do
				r, g, b, a = data:getPixel(charX + x, y)
				if a == 0 then
					fontTable[char][y + 1][x + 1] = 0
				else 
					fontTable[char][y + 1][x + 1] = 1
				end
			end

		end

	end

	--'http://github.com/kikito/inspect.lua'
	--local inspect = require 'inspect'

	--love.filesystem.write("fontSpriteSheetTable.txt", inspect(fontTable))

	--print(inspect(fontTable))


	local fontStr = ''
	for y=0, height - 1 do
		for x=0, width - 1 do
			r, g, b, a = data:getPixel(x, y)
			if a == 0 then
				fontStr = fontStr .. '0,'
			elseif g > 0.5 and b > 0.5 then
				fontStr = fontStr .. '7,'
			else
				fontStr = fontStr .. '8,'
			end
		end
		fontStr = fontStr .. '\n'
	end

    --love.filesystem.write("fontSpriteSheet.txt",fontStr)
    
end
