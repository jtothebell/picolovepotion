local _PACKAGE = (...):match("^(.+)%.[^%.]+")
local json = require(_PACKAGE .. '.json')

local oldNewFont = love.graphics.newFont
function love.graphics.newFont(path)
    if type(path) ~= "string" then
        return oldNewFont(path)
    end

    local pngInfo = love.filesystem.getInfo(path .. ".png")
    local jsonInfo = love.filesystem.getInfo(path .. ".json")
    if pngInfo.type ~= "file" then
        error("Missing " .. path .. ".png!")
    elseif jsonInfo.type ~= "file" then
        error("Missing " .. path .. ".json!")
    end

    local font = {}

    font.glyphs = json:decode(love.filesystem.read(path .. ".json"))
    font.bitmap = love.graphics.newImage(path .. ".png")
    font.size = font.glyphs.info.size
    font.chars = {}

    for k, v in pairs(font.glyphs.chars) do
        font.chars[k:char()] =
        {
            glyph = k:char(), 
            quad = love.graphics.newQuad(v.x, v.y, v.width, v.height, font.bitmap:getWidth(), font.bitmap:getHeight()), 
            xadvance = v.xadvance, 
            xoffset = v.xoffset, 
            yoffset = v.yoffset,
        }
    end

    function font:getWidth(text)
        local width = 0

        text = tostring(text)

        for i = 1, #text do
            if font.chars[text:sub(i, i)] then
                width = width + font.chars[text:sub(i, i)].xadvance
            end
        end

        return width
    end

    function font:getHeight()
        return font.glyphs.common.lineHeight
    end

    return font
end