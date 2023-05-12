Communication = {
    protocol = "EVB_TeamTurtles",
    messages = {
        requestLayer = "requestLayer"
    }
}

function Communication.sendRequest(id, msg)
    local secondsElapsed = 0
    while true do
        rednet.send(id, msg, Communication.protocol)
        id, msg = rednet.receive(Communication.protocol, 10)

        if msg then
            return msg
        end

        secondsElapsed = secondsElapsed + 10
        BroadcastError("Cannot reach '" .. id .. "'.")
    end
end

function Communication.requestLayer(serverAddress, projectId, previousLayer)
    return AssignedLayer + 1

    -- local payload = {
    --     message = Communication.messages.requestLayer,
    --     previousLayer = previousLayer,
    --     projectId = projectId
    -- }

    -- return Communication.sendRequest(serverAddress, textutils.serialize(payload))
end

function Communication.getProject(serverAddress)
    return {
        serverAddress = 1,
        projectId = 1,
        width = 10,
        height = 9,
        workingSide = "right"
    }
end
