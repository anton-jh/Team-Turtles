require("shared.communication")
require("turtle.globalState")
require("turtle.persistence")
require("turtle.misc")
require("turtle.core")
require("turtle.movement")
require("turtle.phases")



function JoinProject(serverId)
    local response = Communication.sendRequest(serverId, Communication.messages.requestLayer)
    Project = textutils.unserialise(response)
    Refuel(true)
    Forward()
    ActivePhase = Phase.outboundFromHome
end



-- MAIN --


-- Args = {...}

-- rednet.open("left")


-- TODO
-- if Args.n == 1 then
--     JoinProject(Args[1])
-- elseif fs.exists(Filenames.instructions) and fs.exists(Filenames.state) then
--     Resume()
-- else
--     print("No saved state to resume. Enter server ID as an argument to connect to a server.")
--     return
-- end



Args = {...}

Project = {
    serverAddress = nil,
    projectId = 1,
    width = Args[1],
    height = Args[2],
    workingSide = Args[3] == "right" and WorkingSide.right or WorkingSide.left
}

AssignedLayer = 1

InitPhase(Phase.outboundFromHome)


while true do
    local steps = ActivePhase.generateSteps()
    local nSteps = #steps;

    CompletedSteps = 0

    while CompletedSteps < nSteps do
        local newPhase = steps[CompletedSteps + 1]()

        if newPhase then
            InitPhase(newPhase)
            break
        end

        CompletedSteps = CompletedSteps + 1
    end
end
