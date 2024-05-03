Phase = {
    inbound = { name = "inbound" },
    outbound = { name = "outbound" },
    resuming = { name = "resuming" },
    working = { name = "working" },
    backtracking = { name = "backtracking" },
    emptyAndRefuel = { name = "emptyAndRefuel" }
}


-- GLOBAL FUNCTIONS


function Resume(steps)
    local moves = InitialFuel - turtle.getFuelLevel()
    local turns, lastTurn, lastTurnCompleted = LoadTurnFile()
    local isBlockInfront, blockInfront = turtle.inspect()
    if not isBlockInfront then
        blockInfront = nil
    end

    print(textutils.serialize({
        moves = moves,
        turns = turns,
        lastTurn = lastTurn and "table" or "nil",
        lastTurnCompleted = lastTurnCompleted
    }))

    if not lastTurnCompleted then
        if blockInfront == lastTurn.blockInfront then
            BroadcastLost("1")
        else
            lastTurnCompleted = true
        end
    end

    local step = 0

    local foundMoves = 0
    while foundMoves < moves do
        step = step + 1
        if IsMove(steps[step]) then
            foundMoves = foundMoves + 1
        elseif steps[step] == nil then
            BroadcastLost("2")
        end
    end
    print("step after moves: " .. step)

    if lastTurn and step > lastTurn.step then
        print("lastTurn and step > lastTurn.step: " .. step)
        return step
    end

    local foundTurns = 0
    while foundTurns < turns do
        step = step + 1
        if IsTurn(steps[step]) then
            if lastTurn and step > lastTurn.step then
                BroadcastLost("3")
            end
            foundTurns = foundTurns + 1
            print("found turn, step: " .. step)
        elseif steps[step] == nil or IsMove(steps[step]) then
            BroadcastLost("4")
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
    elseif args.from > 0 then
        table.insert(steps, Up)
        table.insert(steps, Forward)
        table.insert(steps, Project.workingSide == WorkingSide.right and Right or Left)
    end

    for _ = args.from + 1, AssignedLayer do
        table.insert(steps, Forward)
    end

    table.insert(steps, Project.workingSide == WorkingSide.right and Right or Left)
    table.insert(steps, Forward)
    table.insert(steps, Down)

    table.insert(steps, function ()
        if LayerProgress and LayerProgress > 0 then
            return Phase.resuming
        else
            return Phase.working
        end
    end)

    return steps
end



-- RESUMING --


function Phase.resuming.generateSteps(args)
    local steps = {}
    local direction = 1 -- 1 = out, 2 = right, 3 = in, 4 = left
    local y = 0
    local x = 0

    for i, step in ipairs(Phase.working.generateSteps()) do
        if i > LayerProgress then
            break
        end

        if step == Down then
            y = y + 1
        elseif step == Right then
            direction = direction == 4 and 1 or (direction + 1)
        elseif step == Left then
            direction = direction == 1 and 4 or (direction - 1)
        elseif step == Forward then
            if direction == 1 then
                x = x + 1
            elseif direction == 3 then
                x = x - 1
            end
        end
    end

    for i = 0, x - 1 do
        table.insert(steps, Forward)
    end

    for i = 0, y - 1 do
        table.insert(steps, Down)
    end

    if direction == 3 then
        table.insert(steps, Right)
        table.insert(steps, Right)
    elseif direction == 2 then
        table.insert(steps, Right)
    elseif direction == 4 then
        table.insert(steps, Left)
    end

    table.insert(steps, function ()
        return Phase.working
    end)

    return steps
end



-- WORKING --


function Phase.working.generateSteps(_)
    local function backtrackToHome()
        LayerProgress = CompletedSteps
        PersistState()

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
    local direction = 1 -- 1 = out, 2 = right, 3 = in, 4 = left
    local y = 0
    local x = 0

    for i, step in ipairs(Phase.working.generateSteps()) do
        if i > args.nDoneSteps then
            break
        end

        if step == Down then
            y = y + 1
        elseif step == Right then
            direction = direction == 4 and 1 or (direction + 1)
        elseif step == Left then
            direction = direction == 1 and 4 or (direction - 1)
        elseif step == Forward then
            if direction == 1 then
                x = x + 1
            elseif direction == 3 then
                x = x - 1
            end
        end
    end

    if direction == 1 then
        table.insert(steps, Right)
        table.insert(steps, Right)
    elseif direction == 2 then
        table.insert(steps, Right)
    elseif direction == 4 then
        table.insert(steps, Left)
    end

    for i = 0, y - 1 do
        table.insert(steps, Up)
    end

    for i = 0, x - 1 do
        table.insert(steps, Forward)
    end

    if args.goHome then
        table.insert(steps, function ()
            return Phase.inbound, { from = AssignedLayer }
        end)
    else
        local prevLayer = AssignedLayer

        table.insert(steps, function ()
            RequestLayer()
            PersistState()
        end)

        table.insert(steps, function ()
            if turtle.getFuelLevel() < CalculateNeededFuel(prevLayer, AssignedLayer) then
                return Phase.inbound, { from = prevLayer }
            else
                return Phase.outbound, { from = prevLayer }
            end
        end)
    end

    return steps
end



-- INBOUND --


function Phase.inbound.generateSteps(args)
    local steps = {}

    table.insert(steps, Forward)
    table.insert(steps, Project.workingSide == WorkingSide.right and Left or Right)

    for i = 1, args.from do
        table.insert(steps, Forward)
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
