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

TurtleRoutine = nil
ServerRoutine = nil

if #Args == 0 then
    TurtleRoutine = InitTurtle(nil)
    ServerRoutine = InitServer(nil)
elseif #Args == 1 then
    TurtleRoutine = InitTurtle(Args[1])
elseif #Args == 3 then
    TurtleRoutine = InitTurtle(os.getComputerID())
    ServerRoutine = InitServer(Args)
end

if TurtleRoutine and ServerRoutine then
    parallel.waitForAny(TurtleRoutine, ServerRoutine)
elseif TurtleRoutine then
    TurtleRoutine()
else
    error("Could not start. There are probably errors above.")
end
