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


function CheckInventoryIsFull()
    return turtle.getItemCount(16) > 0
end


function IsInteresting(blockData)
    local result = true
    local opcode = nil
    local filterText = nil
    local subResult = nil

    for _, line in pairs(Project.filters) do
        opcode = string.sub(line, 1, 2)
        filterText = string.sub(line, 4, -1)
        subResult = FilterFunctions[opcode](filterText, blockData)
        if subResult ~= nil then
            result = subResult
        end
    end

    return result
end

FilterFunctions = {
    ["++"] = function (filter, blockData) return true end,
    ["--"] = function (filter, blockData) return false end,
    ["+n"] = function (filter, blockData)
        if blockData.name == filter then
            return true
        end
        return nil
    end,
    ["-n"] = function (filter, blockData)
        if blockData.name == filter then
            return false
        end
        return nil
    end,
    ["+t"] = function (filter, blockData)
        if blockData.tags[filter] == true then
            return true
        end
        return nil
    end,
    ["-t"] = function (filter, blockData)
        if blockData.tags[filter] == true then
            return false
        end
        return nil
    end
}



-- REFUELING --


function CalculateNeededFuel()
    local neededFuel = 0
    neededFuel = neededFuel + AssignedLayer * 2
    neededFuel = neededFuel + (Project.width * Project.height / 3) * 2
    neededFuel = neededFuel + Project.height * 2
    neededFuel = neededFuel + 20
    neededFuel = math.max(neededFuel, MinimumNeededFuel)
    print("Needed fuel = " .. neededFuel)
    return neededFuel
end

function Refuel(refuelPosition)
    local function suckFuelInfront()
        turtle.suck(1)
        return turtle.getItemCount() > 0
    end
    local function suckFuelBelow()
        turtle.suckDown(1)
        return turtle.getItemCount() > 0
    end

    local neededFuel = CalculateNeededFuel()

    turtle.select(1)
    while turtle.getFuelLevel() < neededFuel do
        if turtle.getItemCount() == 0 then
            Ensure(refuelPosition == RefuelPosition.home and suckFuelInfront or suckFuelBelow,
                true, "Cannot refuel.", "Got fuel.")
        end

        if not turtle.refuel() then
            if refuelPosition == RefuelPosition.spawn then
                error("Cannot refuel, non-fuel items in fuel chest!")
            end
            Ensure(turtle.dropDown, true, "Cannot empty.", "Emptied successfully.")
        end
    end

    print("Fuel level = " .. turtle.getFuelLevel())
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
        BroadcastFatalError("Decomissioned.")
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
        rednet.send(id, msg, Communication.protocol.request)
        local responseId, responseMsg = rednet.receive(Communication.protocol.response, 10)

        if responseId == id then
            return responseMsg
        end

        BroadcastError("Cannot reach '" .. id .. "'.")
    end
end
