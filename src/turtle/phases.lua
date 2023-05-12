Phase = {
    inbound = { name = "inbound" },
    outbound = { name = "outbound" },
    working = { name = "working" },
    backtracking = { name = "backtracking" },
    emptyAndRefuel = { name = "emptyAndRefuel" }
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

function InitPhase(phase, args)
    ActivePhase = phase
    PhaseArgs = args
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



-- OUTBOUND --


function Phase.outbound.generateSteps(args)
    local steps = {}

    if args.from == 0 then
        table.insert(steps, Right)
        table.insert(steps, Right)
        table.insert(steps, Up)
    end

    for _ = args.from + 1, AssignedLayer do
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



-- WORKING --


function Phase.working.generateSteps(_)
    local function backtrackToHome()
        return Phase.backtracking, {
            nDoneSteps = CompletedSteps,
            goHome = true
        }
    end


    local steps = {}

    for y = 1, Project.height / 3 do
        for _ = 1, Project.width - 3 do
            table.insert(steps, MineAbove(backtrackToHome))
            table.insert(steps, MineBelow(backtrackToHome))
            table.insert(steps, MineInfront(backtrackToHome))
            table.insert(steps, Forward)
        end

        table.insert(steps, MineAbove(backtrackToHome))
        table.insert(steps, MineInfront(backtrackToHome))

        if y < Project.height / 3 then
            for _ = 1, 3 do
                table.insert(steps, MineBelow(backtrackToHome))
                table.insert(steps, Down)
                table.insert(steps, MineInfront(backtrackToHome))
            end
            table.insert(steps, Left)
            table.insert(steps, Left)
        else
            table.insert(steps, MineBelow(backtrackToHome))
        end
    end

    table.insert(steps, function ()
        return Phase.backtracking, {
            nDoneSteps = CompletedSteps,
            goHome = false
        }
    end)

    return steps
end



-- BACKTRACKING --


function Phase.backtracking.generateSteps(args)
    local steps = {}
    local doneSteps = {}

    for i, step in ipairs(Phase.working.generateSteps()) do
        if i > args.nDoneSteps then
            break
        end

        table.insert(doneSteps, step)
    end

    table.insert(steps, Left)
    table.insert(steps, Left)

    for i = args.nDoneSteps, 1, -1 do
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

    if args.goHome then
        table.insert(steps, Forward)
        table.insert(steps, Project.workingSide == WorkingSide.right and Left or Right)

        table.insert(steps, function ()
            return Phase.inbound
        end)
    else
        local prevLayer = AssignedLayer

        table.insert(steps, function ()
            AssignedLayer = RequestLayer(Project.serverAddress, Project.id, AssignedLayer)
            PersistState()
        end)
        table.insert(steps, Up)
        table.insert(steps, Forward)
        table.insert(steps, Project.workingSide == WorkingSide.right and Right or Left)

        table.insert(steps, function ()
            return Phase.outbound, { from = prevLayer }
        end)
    end

    return steps
end



-- INBOUND --


function Phase.inbound.generateSteps(_)
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


function Phase.emptyAndRefuel.generateSteps(_)
    local refuelStep = function ()
        for i = 1, 16 do
            turtle.select(i)
            Ensure(function ()
                return turtle.getItemCount(i) == 0 or turtle.dropDown()
            end, true, "Cannot empty.", "Emptied successfully.")
        end

        Refuel(RefuelPosition.home)

        return Phase.outbound, {
            from = 0
        }
    end

    return { refuelStep }
end
