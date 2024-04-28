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
    EndTurn()
end

function Left()
    StartTurn()
    turtle.turnLeft()
    EndTurn()
end



-- RECORD-KEEPING --


function ResetTurnFile()
    if TurnFile then
        TurnFile.close()
        TurnFile = nil
    end
    if fs.exists(Filenames.turnFile) then
        fs.delete(Filenames.turnFile)
    end
end

function StartTurn()
    if not TurnFile then
        if fs.exists(Filenames.turnFile) then
            fs.delete(Filenames.turnFile)
        end
        TurnFile = fs.open(Filenames.turnFile, "w")
    end
    local any, data = turtle.inspect()
    TurnFile.writeLine(textutils.serialize({
        blockInfront = any and data.name or nil
    }))
end

function EndTurn()
    if not TurnFile then
        if fs.exists(Filenames.turnFile) then
            fs.delete(Filenames.turnFile)
        end
        TurnFile = fs.open(Filenames.turnFile, "w")
    end
    TurnFile.writeLine("ok")
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
