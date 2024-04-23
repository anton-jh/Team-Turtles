require("communication")
require("constants")
require("utils")
require("globalState")
require("persistence")
require("misc")
require("core")
require("movement")
require("phases")



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
    ResumeProgram()
elseif #Args == 1 then
    StartClient(Args[1])
elseif #Args == 3 then
    StartServer(Args[1], Args[2], Args[3])
end




function ResumeProgram()
    -- todo figure out if server or client or nothing
end

function StartClient(arg1)
    local serverId = tonumber(arg1)
    if serverId == nil then
        print("'" .. arg1 .. "' is not a valid server id. Expected positive integer.")
        return false
    end
end

function StartServer(arg1, arg2, arg3)
    local width = tonumber(arg1)
    local height = tonumber(arg2)
    local side = arg3

    if not width or width <= 0 or not height or height <= 0 or (side ~= WorkingSide.right and side ~= WorkingSide.left) then
        error("Usage: server <width> <height> <right|left>")
    end
    if height % 3 ~= 0 then
        error("Height must be divisible by 3!")
    end


end
