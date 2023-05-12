-- MINING, MAIN FUNCTIONS --


function Mine(nextPhaseIfFull, inspectFunction, digFunction)
    local any, data = inspectFunction()

    if any and IsInteresting(data) then
        if CheckInventoryIsFull() then
            return nextPhaseIfFull
        end
        digFunction()
    end
end


function MineInfront(nextPhaseIfFull)
    return function ()
        return Mine(nextPhaseIfFull, turtle.inspect, turtle.dig)
    end
end

function MineAbove(nextPhaseIfFull)
    return function ()
        return Mine(nextPhaseIfFull, turtle.inspectUp, turtle.digUp)
    end
end

function MineBelow(nextPhaseIfFull)
    return function ()
        return Mine(nextPhaseIfFull, turtle.inspectDown, turtle.digDown)
    end
end



-- MINING, HELPERS --


function IsInteresting(blockData)
    return blockData.tags["c:ores"]
end

function CheckInventoryIsFull()
    return turtle.getItemCount(16) > 0
end



-- REFUELING --


function Refuel(refuelPosition)
    local function suckFuelInfront()
        turtle.suck()
        return turtle.getItemCount() > 0
    end
    local function suckFuelBelow()
        turtle.suckDown()
        return turtle.getItemCount() > 0
    end

    local neededFuel = 0
    neededFuel = neededFuel + AssignedLayer * 2
    neededFuel = neededFuel + Project.width * Project.height / 3
    neededFuel = neededFuel + Project.height * 2
    neededFuel = neededFuel + 10
    neededFuel = neededFuel + (refuelPosition == RefuelPosition.spawn and 1 or 0)
    neededFuel = math.max(neededFuel, MinimumNeededFuel)

    turtle.select(1)
     while turtle.getFuelLevel() < neededFuel do
        Ensure(refuelPosition == RefuelPosition.home and suckFuelInfront or suckFuelBelow,
            true, "Cannot refuel.", "Got fuel.")

        if not turtle.refuel() then
            if refuelPosition == RefuelPosition.spawn then
                return false
            end
            Ensure(turtle.dropDown, true, "Cannot empty.", "Emptied successfully.")
        end
     end

     return true
end
