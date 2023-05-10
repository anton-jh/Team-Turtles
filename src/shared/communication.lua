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
    local payload = {
        message = Communication.messages.requestLayer,
        previousLayer = previousLayer,
        projectId = projectId
    }

    return Communication.sendRequest(serverAddress, textutils.serialize(payload))
end
