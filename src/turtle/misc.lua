-- CONSTANTS --


WorkingSide = {
    left = "left",
    right = "right"
}

TurtleBlockTag = "computercraft:turtle"

RefuelPosition = {
    home = 1,
    spawn = 2
}

MinimumNeededFuel = 200



-- MISC FUNCTIONS --


function Me()
---@diagnostic disable-next-line: undefined-field
    return "TT_" .. os.getComputerID() .. "@" .. Project.serverAddress
end

function BroadcastError(msg)
    rednet.broadcast("!! " .. Me() .. ": " .. msg)
end

function BroadcastSuccess(msg)
    rednet.broadcast("## " .. Me() .. ": " .. msg)
end

function Ensure(fun, expect, errorMessage, resolveMessage)
    local announced = false

    if fun() == expect then
        return
    end

    while true do
        for _ = 1, 10 do
            sleep(1)
            if fun() == expect then
                if announced and resolveMessage then
                    BroadcastSuccess(resolveMessage)
                end
                return
            end
        end
        BroadcastError(errorMessage)
        announced = true
    end
end
