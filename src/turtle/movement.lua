-- MOVEMENT --


function Forward()
    YieldForTurtle(TurtleInfront)
    repeat
        turtle.attack()
        turtle.dig()
    until turtle.forward()
    ResetTurnFile()
end

function Up()
    YieldForTurtle(TurtleAbove)
    repeat
        turtle.attackUp()
        turtle.digUp()
    until turtle.up()
    ResetTurnFile()
end

function Down()
    YieldForTurtle(TurtleBelow)
    repeat
        turtle.attackDown()
        turtle.digDown()
    until turtle.down()
    ResetTurnFile()
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
