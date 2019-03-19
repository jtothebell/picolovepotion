function add(a, v)
	if a==nil then return end
	a[#a+1]=v
end

function del(a, dv)
	if a==nil then return end
	for i=1, #a do
		if a[i]==dv then
			table.remove(a, i)
			return
		end
	end
end

function love.load()
	currentButton =
    {
        pressed = 'None',
        released = 'None'
    }
	currentButtonDown = {}

    local down, OS = "plus", {love.system.getOS()}
    if OS[2] == "3DS" then
        down = "start"
    end
    exitKey = down
end

function love.update(dt)

end

function love.draw()
	love.graphics.print("Hello World!", 10, 10)
	
	local i = 0
    for k, v in pairs(currentButton) do
        love.graphics.print(k .. ": " .. v, 100, 100 + (i * 18))
        i = i + 1
       end
end

function love.gamepadpressed(joy, button)
    if button == exitKey then
        love.event.quit()
    else
        currentButton.pressed = button
		add(currentButtonDown, button)
    end
end

function love.gamepadreleased(joy, button)
    currentButton.released = button
	del(currentButtonDown, button)
end