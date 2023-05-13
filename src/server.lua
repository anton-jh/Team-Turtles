require("shared.communication")
require("shared.constants")



-- STATE --


State = nil



-- FUNCTIONS --


function SaveState()
    local fileHandle = fs.open("state", "w")
    fileHandle.write(textutils.serialize(State))
    fileHandle.close()
end



-- MESSAGE HANDLERS --


MessageHandlers = {
    [Communication.messages.getProject] = function (payload, id)
        return State.project
    end,

    [Communication.messages.requestLayer] = function (payload, id)
        if payload.projectId ~= State.projectId then
            return {
                layer = nil
            }
        end

        if payload.previousLayer ~= 0 and State.turtles[id] ~= payload.previousLayer then
            return {
                layer = State.turtles[id]
            }
        end

        local newLayer = #State.layers + 1
        State.layers[newLayer] = id
        State.layers[payload.previousLayer] = false
        State.turtles[id] = newLayer
        SaveState()

        return {
            layer = newLayer
        }
    end
}



-- MAIN --


rednet.close("back")
rednet.open("back")

Args = { ... }


if fs.exists("state") then
    local fileHandle = fs.open("state", "r")
    State = textutils.unserialize(fileHandle.readAll())
    fileHandle.close()
end

---@diagnostic disable-next-line: undefined-field
if #Args > 0 then
    local width = tonumber(Args[1])
    local height = tonumber(Args[2])
    local side = Args[3]

    if not width or width <= 0 or not height or height <= 0 or (side ~= WorkingSide.right and side ~= WorkingSide.left) then
        error("Usage: server <width> <height> <right|left>")
    end
    if height % 3 ~= 0 then
        error("Height must be divisible by 3!")
    end

    local prevProjectId = State and State.project.projectId or 0

    State = {
        layers = {},
        turtles = {},
        project = {}
    }

---@diagnostic disable-next-line: undefined-field
    State.project.serverAddress = os.getComputerID()
    State.project.projectId = prevProjectId + 1
    State.project.width = width
    State.project.height = height
    State.project.workingSide = side

    SaveState()
end

if not fs.exists("state") and #Args == 0 then
    error("Usage: server <width> <height> <right|left>")
end


while true do
    term.setCursorPos(1, 1)
    term.clear()

    print("---- TeamTurtles Server")
    print()
    print(textutils.serialize(State.project))
    print()
    for layer, turtleId in pairs(State.layers) do
        print(layer .. " - " .. (turtleId or "DONE"))
    end

    local id, msg = rednet.receive(Communication.protocol)

    local payload = textutils.unserialize(msg)
    local response = MessageHandlers[payload.message](payload, id)

    sleep(0.1)

    rednet.send(id, textutils.serialize(response), Communication.protocol)
end
