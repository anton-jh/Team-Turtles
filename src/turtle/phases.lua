Phase = {
    inbound = { name = "inbound" },
    outboundFromHome = { name = "outboundFromHome" },
    outboundFromLayer = { name = "outboundFromLayer" },
    working = { name = "working" },
    backtrackingToHome = { name = "backtrackingToHome" },
    backtrackingToNextLayer = { name = "backtrackingToNextLayer" },
    emptyAndRefuel = { name = "emptyAndRefuel" }
}


-- GLOBAL FUNCTIONS


function Resume(initialFuel, turns, steps)
    local moves = initialFuel - turtle.getFuelLevel()

    local step = 0

    local foundMoves = 0
    while foundMoves < moves do
        step = step + 1
        if IsMove(steps[step]) then
            foundMoves = foundMoves + 1
        elseif steps[step] == nil then
            BroadcastError("Cannot resume.")
            error("ERROR: Cannot resume from saved state. Turtle has consumed more fuel than expected.")
        end
    end

    local foundTurns = 0
    while foundTurns < turns do
        step = step + 1
        if IsTurn(steps[step]) then
            foundTurns = foundTurns + 1
        elseif steps[step] == nil or IsMove(steps[step]) then
            BroadcastError("Cannot resume.")
            error("ERROR: Cannot resume from saved state. Saved state is invalid.")
        end
    end

    return step + 1
end

function InitPhase(phase)
    ActivePhase = phase
    InitialFuel = turtle.getFuelLevel()

    ResetTurnFile()
    PersistState()
end



-- HELPERS --


function IsMove(func)
    return func == Forward or func == Up or func == Down
end

function IsTurn(func)
    return func == Left or func == Right
end

function GenerateBacktrackPhase(doneSteps)
    local steps = {}

    steps:insert(Left)
    steps:insert(Left)

    for i = #doneSteps, 1, -1 do
        local step = doneSteps[i]

        if step == Forward then
            steps:insert(Forward)
        elseif step == Up then
            steps:insert(Down)
        elseif step == Down then
            steps:insert(Up)
        elseif step == Left then
            steps:insert(Right)
        elseif step == Right then
            steps:insert(Left)
        end
    end
end

function GenerateOutboundPhase(from)
    local steps = {}

    for _ = from + 1, AssignedLayer do
        steps:insert(Forward)
    end

    steps:insert(Project.workingSide == WorkingSide.right and Right or Left)
    steps:insert(Forward)
    steps:insert(Down)

    steps:insert(function ()
        return Phase.working
    end)

    return steps
end



-- OUTBOUND_FROM_HOME --


function Phase.outboundFromHome.generateSteps()
    return GenerateOutboundPhase(0)
end



-- OUTBOUND_FROM_LAYER --


function Phase.outboundFromLayer.generateSteps()
    return GenerateOutboundPhase(PreviousLayer)
end



-- WORKING --


function Phase.working.generateSteps()
    local steps = {}

    for y = 1, Project.height / 3 do
        for _ = 1, Project.width - 3 do
            steps:insert(MineAbove(Phase.backtrackingToHome))
            steps:insert(MineBelow(Phase.backtrackingToHome))
            steps:insert(Forward)
        end

        steps:insert(MineAbove(Phase.backtrackingToHome))
        steps:insert(MineInfront(Phase.backtrackingToHome))

        if y < Project.height / 3 then
            for _ = 1, 3 do
                steps:insert(Down)
                steps:insert(MineInfront(Phase.backtrackingToHome))
            end
            steps:insert(Left)
            steps:insert(Left)
        else
            steps:insert(MineBelow(Phase.backtrackingToHome))
        end
    end

    steps:insert(function ()
        return Phase.backtrackingToNextLayer
    end)

    return steps
end



-- BACKTRACKING_TO_HOME --


function Phase.backtrackingToHome.generateSteps()
    local steps = GenerateBacktrackPhase(CompletedSteps)

    steps:insert(Forward)
    steps:insert(Project.workingSide == WorkingSide.right and Left or Right)

    steps:insert(function ()
        return Phase.inbound
    end)

    return steps
end



-- BACKTRACKING_TO_NEXT_LAYER --


function Phase.backtrackingToNextLayer.generateSteps()
    local steps = GenerateBacktrackPhase(CompletedSteps)

    steps:insert(function ()
        PreviousLayer = AssignedLayer
        AssignedLayer = Communication.requestLayer(Project.serverAddress, Project.id, AssignedLayer)
        PersistState()
    end)
    steps:insert(Up)
    steps:insert(Forward)
    steps:insert(Project.workingSide == WorkingSide.right and Right or Left)

    steps:insert(function ()
        return Phase.outboundFromLayer
    end)

    return steps
end



-- INBOUND --


function Phase.inbound.generateSteps()
    local steps = {}

    for i = 1, AssignedLayer do
        steps[i] = Forward
    end

    steps:insert(function ()
        return Phase.emptyAndRefuel
    end)

    return steps
end



-- EMPTY_AND_REFUEL --


function Phase.emptyAndRefuel.generateSteps()
    local refuelStep = function ()
        for i = 1, 16 do
            turtle.select(i)
            Ensure(turtle.dropDown, true, "Cannot empty.", "Emptied successfully.")
        end

        Refuel(RefuelPosition.home)

        return Phase.outboundFromHome
    end

    return { refuelStep }
end
