-- MOVEMENT --


function Forward()
    YieldForTurtle(TurtleInfront)
    repeat
        turtle.attack()
        turtle.dig()
    until turtle.forward()
    RecordMove()
end

function Up()
    YieldForTurtle(TurtleAbove)
    repeat
        turtle.attackUp()
        turtle.digUp()
    until turtle.up()
    RecordMove()
end

function Down()
    YieldForTurtle(TurtleBelow)
    repeat
        turtle.attackDown()
        turtle.digDown()
    until turtle.down()
    RecordMove()
end

function Right()
    turtle.turnRight()
    RecordTurn()
end

function Left()
    turtle.turnLeft()
    RecordTurn()
end



-- RECORD-KEEPING --


TurnFile = nil
HasMovedSinceLastTurn = false

function RecordTurn()
    if HasMovedSinceLastTurn then
        TurnFile = fs.open(Filenames.turnFile, "w")
    end

    TurnFile.write("t")
    HasMovedSinceLastTurn = false
end

function ResetTurnFile()
    if fs.exists(Filenames.turnFile) then
        fs.delete(Filenames.turnFile)
    end
end

function RecordMove()
    if HasMovedSinceLastTurn then
        return
    end
    HasMovedSinceLastTurn = true

    if TurnFile then
        TurnFile.close()
        TurnFile = nil
    end

    ResetTurnFile()
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
