function Write(text, y, x)
    if not x then
        x = 1
    end
    term.setCursorPos(x, y)
    term.write(text)
end

function WriteCenter(text, y)
    if not y then
        _, y = term.getCursorPos()
        y = y + 1
    end
    local w, _ = term.getSize()
    local x = math.ceil(w / 2 - text:len() / 2)
    Write(text, y, x)
end
