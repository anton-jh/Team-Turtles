turtle = {}

local gItemDetails = { {name="torch"}, {name="chest"}, {name="random"}}
local gSlotNum = 1

function turtle.refuel()
  print("refuel")
end

function turtle.digUp()
  print("digUp")
end

function turtle.suck()
  print("suck")
end

function turtle.down()
  print("down")
end

function turtle.turnLeft()
  print("turnLeft")
end

function turtle.turnRight()
  print("turnRight")
end

function turtle.digDown()
  print("digDown")
end

function turtle.dig()
  print("dig")
end

function turtle.forward()
  print("forward")
end

function turtle.back()
  print("back")
end

function turtle.up()
  print("up")
end

function turtle.place()
  print("place")
end

function turtle.drop()
  print("drop")
end

function turtle.inspectDown()
  print("inspectDown")
end

function turtle.inspect()
  print("inspect")
  return false, nil
end

function turtle.select(slotNum)
  gSlotNum = slotNum
end

function turtle.getItemCount(slotNum)
  return math.random(64);
end

function turtle.getItemDetail()
  local value = gItemDetails[gSlotNum];
  if value ~= nil then
    return value
  else
    return {name="random"}
  end
end

function turtle.getFuelLevel()
    return 10
end
