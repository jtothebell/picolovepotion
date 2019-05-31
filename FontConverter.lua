function writeFontToText()

    local data=love.image.newImageData("font32bit.png")

	local width,height = data:getDimensions()
    local fontStr = ''
    local x = 0
    local y = 0
    while x < width do
        


    end

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

    love.filesystem.write("fontSpriteSheet.txt",fontStr)
    
end
