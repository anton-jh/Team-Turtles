require("constants")
require("core")
require("globalState")
require("misc")
require("movement")
require("persistence")
require("phases")
require("server")
require("turtle")



for _, side in pairs({
    "top",
    "bottom",
    "left",
    "right",
    "front",
    "back"
}) do
    if peripheral.hasType(side, "modem") then
        rednet.close(side)
        rednet.open(side)
        break
    end
end


Args = { ... }

if #Args == 0 then
    parallel.waitForAll(function ()
        RunTurtle(nil)
    end, function ()
        RunServer(nil)
    end)
elseif #Args == 1 then
    if Args[1] == os.getComputerID() then
        parallel.waitForAll(function ()
            RunTurtle(os.getComputerID())
        end, function ()
            RunServer(nil)
        end)
    else
        RunTurtle(Args[1])
    end
elseif #Args == 3 then
    parallel.waitForAny(function ()
        RunTurtle(os.getComputerID())
    end, function ()
        RunServer(Args)
    end)
end

-- TODO: clear previous state if starting new session, but preserve project id (or generate random each time if possible? math.random?)
