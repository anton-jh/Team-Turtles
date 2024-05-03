-- FUNCTIONS --


function RunTurtle(arg)
    if not arg then
        LoadProject()
        LoadState()
        CompletedSteps = Resume(ActivePhase.generateSteps(PhaseArgs))
        Resuming = true
    else
        local serverId = tonumber(arg)
        if not serverId then
            return false
        end
        FetchProject(serverId)
        PersistProject()
        RequestLayer()
        Refuel(RefuelPosition.spawn)
        InitPhase(Phase.outbound, { from = -1 })
    end

    os.setComputerLabel(os.getComputerID() .. "@" .. Project.serverAddress)

    while true do
        local steps = ActivePhase.generateSteps(PhaseArgs)
        local nSteps = #steps

        if not Resuming then
            CompletedSteps = 0
        else
            Resuming = false
        end
        if ActivePhase.name == Phase.working.name then
            CompletedSteps = LayerProgress or 0
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
end

function ClearTurtle()
    local files = {
        Filenames.project,
        Filenames.state,
        Filenames.turnFile
    }
    for _, filename in pairs(files) do
        if fs.exists(filename) then
            fs.delete(filename)
        end
    end
end
