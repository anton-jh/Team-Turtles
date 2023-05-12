if fs.exists("state") then
    local fileHandle = fs.open("state", "r")
    State = textutils.unserialize(fileHandle.readAll())
else
    State = {
        projectId = 1,
        layers = {}
    }
end


while true do
    local id, msg = rednet.receive("")
end
