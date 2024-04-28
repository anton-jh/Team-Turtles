-- MOVEMENT --


function Forward()
    YieldForTurtle(TurtleInfront)
    while not turtle.forward() do
        turtle.attack()
        turtle.dig()
    end
    ResetTurnFile()
end

function Up()
    YieldForTurtle(TurtleAbove)
    while not turtle.up() do
        turtle.attackUp()
        turtle.digUp()
    end
    ResetTurnFile()
end

function Down()
    YieldForTurtle(TurtleBelow)
    while not turtle.down() do
        turtle.attackDown()
        turtle.digDown()
    end
    ResetTurnFile()
end

function Right()
    StartTurn()
    turtle.turnRight()
    RecordTurn()
    EndTurn()
end

function Left()
    StartTurn()
    turtle.turnLeft()
    RecordTurn()
    EndTurn()
end



-- RECORD-KEEPING --


function RecordTurn()
    if not TurnFile then
        TurnFile = fs.open(Filenames.turnFile, "w")
    end

    TurnFile.write("t")
end

function ResetTurnFile()
    if TurnFile then
        TurnFile.close()
        TurnFile = nil
    end
    if fs.exists(Filenames.turnFile) then
        fs.delete(Filenames.turnFile)
    end
end

function StartTurn(targetDirection)
    local any, data = turtle.inspect()
    ClearTable(Filenames.turnLock)
    SaveTable(Filenames.turnLock, {
        direction = targetDirection,
        blockInfront = any and data.name or ""
    })
end

function EndTurn()
    ClearTable(Filenames.turnLock)
end


-- ANTI-COLLISION --


function TurtleInfront()
    local any, data = turtle.inspect()
    return any and data.tags[TurtleBlockTag]
end

function TurtleAbove()
    local any, data = turtle.inspectUp()
    return any and data.tags[TurtleBlockTag]
end

function TurtleBelow()
    local any, data = turtle.inspectDown()
    return any and data.tags[TurtleBlockTag]
end


function YieldForTurtle(checkFunction)
    Ensure(checkFunction, false, "Blocked by other turtle.", "Unblocked.")
end
