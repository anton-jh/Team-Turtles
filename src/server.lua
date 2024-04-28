



-- STATE --


ServerState = nil



-- FUNCTIONS --


function RunServer(args)
    local loadedState = nil

    if fs.exists(Filenames.serverState) then
        local fileHandle = fs.open(Filenames.serverState, "r")
        loadedState = textutils.unserialize(fileHandle.readAll())
        fileHandle.close()
    end

    if args then
        local width = tonumber(args[1])
        local height = tonumber(args[2])
        local side = args[3]

        if not width or width <= 0 or not height or height <= 0 or (side ~= WorkingSide.right and side ~= WorkingSide.left) then
            error("Usage: <width> <height> <right|left>")
            return false
        end
        if height % 3 ~= 0 then
            error("Height must be divisible by 3!")
            return false
        end

        ServerState = {
            layers = {},
            turtles = {},
            project = {}
        }

        ServerState.project.serverAddress = os.getComputerID()
        ServerState.project.projectId = os.epoch()
        ServerState.project.width = width
        ServerState.project.height = height
        ServerState.project.workingSide = side
        ServerState.project.filters = LoadFilters()

        SaveServerState()
    elseif loadedState then
        ServerState = loadedState
    else
        print("No server session to resume.")
        return false
    end

    while true do
        local id, msg = rednet.receive(Communication.protocol.request)

        local payload = textutils.unserialize(msg)
        local response = MessageHandlers[payload.message](payload, id)

        sleep(0.1)
        rednet.send(id, textutils.serialize(response), Communication.protocol.response)
    end
end

function ClearServer()
    if fs.exists(Filenames.serverState) then
        fs.delete(Filenames.serverState)
    end
end

function SaveServerState()
    local fileHandle = fs.open(Filenames.serverState, "w")
    fileHandle.write(textutils.serialize(ServerState))
    fileHandle.close()
end



-- MESSAGE HANDLERS --


MessageHandlers = {
    [Communication.messages.getProject] = function (payload, id)
        return ServerState.project
    end,

    [Communication.messages.requestLayer] = function (payload, id)
        if payload.projectId ~= ServerState.project.projectId then
            return {
                layer = nil
            }
        end

        if payload.previousLayer ~= ServerState.turtles[id] or (not payload.previousLayer and ServerState.turtles[id]) then
            return {
                layer = ServerState.turtles[id]
            }
        end

        local newLayer = #ServerState.layers + 1
        ServerState.layers[newLayer] = id
        if payload.previousLayer then
            ServerState.layers[payload.previousLayer] = false
        end
        ServerState.turtles[id] = newLayer
        SaveServerState()

        return {
            layer = newLayer
        }
    end
}
