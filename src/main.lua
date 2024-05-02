require("constants")
require("core")
require("globalState")
require("misc")
require("movement")
require("persistence")
require("phases")
require("server")
require("turtle")



function Install()
    local programName = shell.getRunningProgram()
    local startupScript = "shell.run(\"" .. programName .. "\")"
    local oppositeNames = {
        ["startup"] = "startup.lua",
        ["startup.lua"] = "startup"
    }

    if programName == "startup" or programName == "startup.lua" then
        if fs.exists(oppositeNames[programName]) then
            fs.move(oppositeNames[programName], os.epoch() .. "_" .. oppositeNames[programName])
        end
        return
    end

    if fs.exists("startup.lua") then
        fs.move("startup.lua", os.epoch() .. "_startup.lua")
    end

    if fs.exists("startup") then
        local readHandle = fs.open("startup", "r")
        local contents = readHandle.readAll()
        readHandle.close()

        if contents == startupScript then
            return
        end

        fs.move("startup", os.epoch() .. "_startup")
    end

    local writeHandle = fs.open("startup", "w")
    writeHandle.write(startupScript)
    writeHandle.close()
end


Install()


for _, side in pairs({
    "left",
    "right",
}) do
    if peripheral.hasType(side, "modem") then
        rednet.close(side)
        rednet.open(side)
        break
    end
end


Args = { ... }

if #Args == 0 then
    print("Turtle resuming in 5 seconds...")
    sleep(5)
    parallel.waitForAll(function ()
        RunTurtle(nil)
    end, function ()
        RunServer(nil)
    end)
elseif #Args == 1 then
    ClearTurtle()
    if tonumber(Args[1]) == os.getComputerID() then
        parallel.waitForAll(function ()
            RunTurtle(os.getComputerID())
        end, function ()
            RunServer(nil)
        end)
    else
        ClearServer()
        RunTurtle(Args[1])
    end
elseif #Args == 3 then
    ClearTurtle()
    ClearServer()
    parallel.waitForAny(function ()
        RunTurtle(os.getComputerID())
    end, function ()
        RunServer(Args)
    end)
end

-- TODO: clear previous state if starting new session, but preserve project id (or generate random each time if possible? math.random?)
