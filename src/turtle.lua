require("shared.communication")
require("turtle.globalState")
require("turtle.persistence")
require("turtle.misc")
require("turtle.core")
require("turtle.movement")
require("turtle.phases")



-- MAIN --


rednet.close("left")
rednet.open("left")


Resuming = false

if fs.exists(Filenames.project) and fs.exists(Filenames.state) then
    LoadProject()
    LoadState()
    CompletedSteps = Resume(LoadTurns(), ActivePhase.generateSteps())
    Resuming = true
else
    local args = {...}
    Project = Communication.getProject(args[1])
    PersistProject()
    AssignedLayer = Communication.requestLayer(Project.serverAddress, Project.projectId, 0)
    Forward()
    InitPhase(Phase.outboundFromHome)
end


while true do
    local steps = ActivePhase.generateSteps()
    local nSteps = #steps

    if not Resuming then
        CompletedSteps = 0
    else
        Resuming = false
    end

    while CompletedSteps < nSteps do
        local newPhase = steps[CompletedSteps + 1]()

        if newPhase then
            InitPhase(newPhase)
            print(newPhase.name)
            break
        end

        CompletedSteps = CompletedSteps + 1
    end
end
