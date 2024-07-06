-- All features related to the turtle in this quarry.

Q_worker = {}

function Q_worker.refuel()
  print(">> Refuel")
  while turtle.getFuelLevel() < turtle.getFuelLimit() and turtle.suckUp() do
    turtle.refuel(64)
  end
  -- Flush the fuel left behind.
  turtle.dropUp()
  -- for cell = 1, 16 do
  --   turtle.select(cell)
  --   turtle.dropUp()
  -- end
  -- turtle.select(1)
end

--- Emtpy inventory into the behind chest.
function Q_worker.emtpyInventory()
  print(">> Empty inventory")
  turtle.turnLeft()
  turtle.turnLeft()

  for cell = 1, 16 do
    turtle.select(cell)
    turtle.drop()
  end
  turtle.select(1)

  turtle.turnRight()
  turtle.turnRight()
end

return Q_worker

-- Returns true if the inventory is full or is about to get full.
function Q_worker.isInventoryFull()
  local totalItems = 0

  for cell = 1, 16 do
    totalItems = turtle.getItemCount(cell) + totalItems
  end

  if totalItems >= 63 * 16 then
    return true
  end

  return false
end

function Q_worker.getInventoryNumItems()
    local totalItems = 0

  for cell = 1, 16 do
    totalItems = turtle.getItemCount(cell) + totalItems
  end

  return totalItems
end

function printStatus()
  -- F stands for Fuel
  -- I stands for Inventory
  local fuel = turtle.getFuelLevel() .."/".. turtle.getFuelLimit()
  local inventory = Q_worker.getInventoryNumItems() .."/".. 1024
  print("F: ".. fuel ..", I: ".. inventory)
end
