-- MISC FUNCTIONS --


function Me()
---@diagnostic disable-next-line: undefined-field
    return "TT_" .. os.getComputerID() .. "@" .. (Project.serverAddress or "_")
end

function BroadcastError(msg, printError)
    if printError ~= false then
        print("!! " .. msg)
    end
    rednet.broadcast("!! " .. Me() .. ": " .. msg)
end

function BroadcastSuccess(msg)
    rednet.broadcast("## " .. Me() .. ": " .. msg)
end

function Ensure(fun, expect, errorMessage, resolveMessage)
    local announced = false

    if not not fun() == expect then
        return
    end

    while true do
        for _ = 1, 10 do
            sleep(1)
            if not not fun() == expect then
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

function BroadcastFatalError(msg, printError)
    for i = 1, 10 do
        BroadcastError(msg, printError)
        sleep(60)
    end
    error(msg)
end

function BroadcastLost(reason)
    term.clear()
    print("I got lost. (Reason: " .. reason .. ") Please:")
    print("- Place me at the spawn")
    print("- Terminate the program")
    print("- Rejoin the project with \"" .. shell.getRunningProgram() .. " " .. Project.serverAddress .. "\"")
    local location = "basecamp"
    if ActivePhase.name == Phase.working.name or ActivePhase.name == Phase.backtracking.name or ActivePhase.name == Phase.resuming.name then
        location = "layer " .. AssignedLayer
    elseif ActivePhase.name == Phase.inbound or ActivePhase.name == Phase.outbound.name then
        location = "corridor"
    end
    BroadcastFatalError("Lost at " .. location .. ".", false)
end
