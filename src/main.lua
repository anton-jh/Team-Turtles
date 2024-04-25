require("communication")
require("constants")
require("utils")
require("globalState")
require("persistence")
require("misc")
require("core")
require("movement")
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
    RunTurtle(Args[1])
elseif #Args == 3 then
    parallel.waitForAny(function ()
        RunTurtle(os.getComputerID())
    end, function ()
        RunServer(Args)
    end)
end
