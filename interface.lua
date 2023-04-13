local interface = {}

interface.font_data_cache = {}

function interface.print_characters(str, font_size)
    self.Font_Data.positioning.x_offset = 0
    self.Font_Data.positioning.max_origin_y = 0

    local rects = {}
    if not (type(font_size) == "number") then
        font_size = 1
    end

    for i = 1, #str do
        local character = string.sub(str, i, i)
        local char_data = interface.font_data_cache[character]
        if not char_data then
            char_data = self.Font_Data.characters[character]
            interface.font_data_cache[character] = char_data
        end
        if char_data then
            if char_data.originY > self.Font_Data.positioning.max_origin_y then
                self.Font_Data.positioning.max_origin_y = char_data.originY
            end
            local x = self.Font_Data.positioning.x_offset - char_data.originX * font_size
            local y = self.Font_Data.positioning.max_origin_y - char_data.originY * font_size
            local width = char_data.width * font_size
            local height = char_data.height * font_size
            local u1 = char_data.x / 765
            local v1 = char_data.y / 257
            local u2 = (char_data.x + char_data.width) / 765
            local v2 = (char_data.y + char_data.height) / 257
            table.insert(rects, {x, y, width, height, u1, v1, u2, v2})
            self.Font_Data.positioning.x_offset = self.Font_Data.positioning.x_offset + char_data.advance * font_size
        end
    end

    GUI:BeginGroup()
    local cursor_x, cursor_y = GUI:GetCursorPos()
    for _, rect in ipairs(rects) do
        GUI:SetCursorPos(cursor_x + rect[1], cursor_y + rect[2])
        GUI:Image(self.Directories.Icons_Path .. "\\output.png", rect[3], rect[4], rect[5], rect[6], rect[7], rect[8])
    end
    GUI:EndGroup()
end

return interface