Communication = {}

Communication.protocol = "EVB_TeamTurtles"
Communication.messages = {
    requestLayer = "requestLayer",
    getProject = "getProject"
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
