Phase = {
    inbound = { name = "inbound" },
    outboundFromHome = { name = "outboundFromHome" },
    outboundFromLayer = { name = "outboundFromLayer" },
    working = { name = "working" },
    backtrackingToHome = { name = "backtrackingToHome" },
    backtrackingToNextLayer = { name = "backtrackingToNextLayer" },
    emptyAndRefuel = { name = "emptyAndRefuel" },
    preOutbound = { name = "preOutBound" }
}


-- GLOBAL FUNCTIONS


function Resume(turns, steps)
    local moves = InitialFuel - turtle.getFuelLevel()

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

    return step
end

function InitPhase(phase)
    ActivePhase = phase
    InitialFuel = turtle.getFuelLevel()

    ResetTurnFile()
    PersistState()
end



-- HELPERS --


function IsMove(func)
    return (func == Forward) or (func == Up) or (func == Down)
end

function IsTurn(func)
    return (func == Left) or (func == Right)
end

function GenerateBacktrackPhase(nDoneSteps)
    local steps = {}
    local doneSteps = {}

    for i, step in ipairs(Phase.working.generateSteps()) do
        if i > nDoneSteps then
            break
        end

        table.insert(doneSteps, step)
    end

    table.insert(steps, Left)
    table.insert(steps, Left)

    for i = nDoneSteps, 1, -1 do
        local step = doneSteps[i]

        if step == Forward then
            table.insert(steps, Forward)
        elseif step == Up then
            table.insert(steps, Down)
        elseif step == Down then
            table.insert(steps, Up)
        elseif step == Left then
            table.insert(steps, Right)
        elseif step == Right then
            table.insert(steps, Left)
        end
    end

    return steps
end

function GenerateOutboundPhase(from)
    local steps = {}

    for _ = from + 1, AssignedLayer do
        table.insert(steps, Forward)
    end

    table.insert(steps, Project.workingSide == WorkingSide.right and Right or Left)
    table.insert(steps, Forward)
    table.insert(steps, Down)

    table.insert(steps, function ()
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
            table.insert(steps, MineAbove(Phase.backtrackingToHome))
            table.insert(steps, MineBelow(Phase.backtrackingToHome))
            table.insert(steps, Forward)
        end

        table.insert(steps, MineAbove(Phase.backtrackingToHome))
        table.insert(steps, MineInfront(Phase.backtrackingToHome))

        if y < Project.height / 3 then
            for _ = 1, 3 do
                table.insert(steps, Down)
                table.insert(steps, MineInfront(Phase.backtrackingToHome))
            end
            table.insert(steps, Left)
            table.insert(steps, Left)
        else
            table.insert(steps, MineBelow(Phase.backtrackingToHome))
        end
    end

    table.insert(steps, function ()
        return Phase.backtrackingToNextLayer
    end)

    return steps
end



-- BACKTRACKING_TO_HOME --


function Phase.backtrackingToHome.generateSteps()
    local steps = GenerateBacktrackPhase(CompletedSteps)

    table.insert(steps, Forward)
    table.insert(steps, Project.workingSide == WorkingSide.right and Left or Right)

    table.insert(steps, function ()
        return Phase.inbound
    end)

    return steps
end



-- BACKTRACKING_TO_NEXT_LAYER --


function Phase.backtrackingToNextLayer.generateSteps()
    local steps = GenerateBacktrackPhase(CompletedSteps)

    table.insert(steps, function ()
        PreviousLayer = AssignedLayer
        AssignedLayer = Communication.requestLayer(Project.serverAddress, Project.id, AssignedLayer)
        PersistState()
    end)
    table.insert(steps, Up)
    table.insert(steps, Forward)
    table.insert(steps, Project.workingSide == WorkingSide.right and Right or Left)

    table.insert(steps, function ()
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

    table.insert(steps, function ()
        return Phase.emptyAndRefuel
    end)

    return steps
end



-- EMPTY_AND_REFUEL --


function Phase.emptyAndRefuel.generateSteps()
    local refuelStep = function ()
        for i = 1, 16 do
            turtle.select(i)
            Ensure(function ()
                return turtle.getItemCount(i) == 0 or turtle.dropDown()
            end, true, "Cannot empty.", "Emptied successfully.")
        end

        Refuel(RefuelPosition.home)

        return Phase.preOutbound
    end

    return { refuelStep }
end



-- PRE_OUTBOUND --


function Phase.preOutbound.generateSteps()
    return {
        Up,
        Right,
        Right,
        function ()
            return Phase.outboundFromHome
        end
    }
end
