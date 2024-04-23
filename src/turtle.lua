-- MAIN --


Resuming = false
Args = { ... }





if fs.exists(Filenames.project) and fs.exists(Filenames.state) and #Args == 0 then
    LoadProject()
    LoadState()
    CompletedSteps = Resume(LoadTurns(), ActivePhase.generateSteps(PhaseArgs))
    Resuming = true
else
    if #Args ~= 1 then
        error("Usage: turtle <serverAddress>")
    end
    FetchProject(tonumber(Args[1]))
    PersistProject()
    RequestLayer()
    Refuel(RefuelPosition.spawn)
    InitPhase(Phase.outbound, { from = -1 })
end


while true do
    local steps = ActivePhase.generateSteps(PhaseArgs)
    local nSteps = #steps

    if not Resuming then
        CompletedSteps = 0
    else
        Resuming = false
    end

    while CompletedSteps < nSteps do
        local newPhase, newPhaseArgs = steps[CompletedSteps + 1]()

        if newPhase then
            InitPhase(newPhase, newPhaseArgs)
            print(newPhase.name)
            break
        end

        CompletedSteps = CompletedSteps + 1
    end
end
