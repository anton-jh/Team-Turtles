-- MINING, MAIN FUNCTIONS --


function Mine(nextPhaseIfFullFunction, inspectFunction, digFunction)
    local any, data = inspectFunction()

    if any and IsInteresting(data) then
        if CheckInventoryIsFull() then
            return nextPhaseIfFullFunction()
        end
        digFunction()
    end
end


function MineInfront(nextPhaseIfFullFunction)
    return function ()
        return Mine(nextPhaseIfFullFunction, turtle.inspect, turtle.dig)
    end
end

function MineAbove(nextPhaseIfFullFunction)
    return function ()
        return Mine(nextPhaseIfFullFunction, turtle.inspectUp, turtle.digUp)
    end
end

function MineBelow(nextPhaseIfFullFunction)
    return function ()
        return Mine(nextPhaseIfFullFunction, turtle.inspectDown, turtle.digDown)
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
                error("Cannot refuel, non-fuel items in fuel chest!")
            end
            Ensure(turtle.dropDown, true, "Cannot empty.", "Emptied successfully.")
        end
    end
end



-- COMMUNICATION --


function RequestLayer()
    local payload = {
        message = Communication.messages.requestLayer,
        previousLayer = AssignedLayer,
        projectId = Project.projectId
    }
    local responseRaw = SendRequest(Project.serverAddress, textutils.serialize(payload))
    local response = textutils.unserialize(responseRaw)

    if not response.layer then
        BroadcastError("Decommissioned.")
    end

    AssignedLayer = response.layer
    print("AssignedLayer = " .. AssignedLayer)
end

function FetchProject(serverAddress)
    local payload = {
        message = Communication.messages.getProject
    }
    local response = SendRequest(serverAddress, textutils.serialize(payload))

    Project = textutils.unserialize(response)
    print("Project = " .. textutils.serialize(Project))
end


function SendRequest(id, msg)
    while true do
        rednet.send(id, msg, Communication.protocol)
        local responseId, responseMsg = rednet.receive(Communication.protocol, 10)
        -- TODO: what id? sender or receiver?
        -- TODO: FIX: in teamlead-mode, the request gets received as a response
        -- possible fix: wait before listening for response (less than the server waits to send response)

        if responseId == id then
            return responseMsg
        end

        BroadcastError("Cannot reach '" .. id .. "'.")
    end
end
