local Q_config = require("Q_config")

function pause(msg)
  if msg == nil then
    msg = ""
  end
  write(msg)
  read()
end

--[[ TURTLE ]]--

function digRow(length)
  for block = 1, length do
    if turtle.detectDown() then
      turtle.digDown()
    end
    if block <= length - 1 then
      turtle.dig()
      turtle.forward()
    end
  end
end

function turnRight()
  turtle.turnRight()
  turtle.dig()
  turtle.forward()
  turtle.turnRight()
end

function turnLeft()
  turtle.turnLeft()
  turtle.dig()
  turtle.forward()
  turtle.turnLeft()
end

function return2Base()
  print(">> Returning to base")
  while Q_config.get("curYLocation") < Q_config.get("startYLocation") do
    turtle.up()
    Q_config.set("curYLocation", Q_config.get("curYLocation") + 1)
    -- config["curYLocation"] = config["curYLocation"] + 1
  end
end

function digLayer(layout, rowLength, numRows)
  print(">> Dig layer")
  print(">> FUEL: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())
  -- Forward (TRUE) -> R,L,R,L...X
  -- Backwards (FALSE) -> L,R,L,R...X
  local nextRow = layout
  local lastRow = numRows

  for row = 1, lastRow do
    digRow(rowLength)

    if row <= (lastRow   - 1) then
      if nextRow then
        turnRight()
      else
        turnLeft()
      end
      nextRow = not nextRow
    end
  end

  -- Set for the next layout.
  turtle.turnLeft()
  turtle.turnLeft()
  turtle.down()
  turtle.digDown()
  turtle.down()
  Q_config.set("curYLocation", Q_config.get("curYLocation") - 2)
  -- config["curYLocation"] = config["curYLocation"] - 1
end

--- Emtpy inventory into the behind chest.
function emtpyInventory()
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

function refuel()
  print(">> Refuel")
  while turtle.getFuelLevel() < turtle.getFuelLimit() and turtle.suckUp() do
    turtle.refuel(64)
  end
  -- Flush the left behind gas.
  for cell = 1, 16 do
    turtle.select(cell)
    turtle.dropUp()
  end
  turtle.select(1)
end

function resume()
  print(">> Resume")
  while Q_config.get("curYLocation") > Q_config.get("resumeYLocation") do
    turtle.down()
    Q_config.set("curYLocation", Q_config.get("curYLocation") - 1)
    -- config["curYLocation"] = config["curYLocation"] - 1
  end
end

-- Returns true if the inventory is full or is about to get full.
function isInventoryFull()
  local totalItems = 0

  for cell = 1, 16 do
    totalItems = turtle.getItemCount(cell) + totalItems
  end

  if totalItems >= 63 * 16 then
    return true
  end

  return false
end

function quarry()
  print(">> BEGIN QUARRY")
  emtpyInventory()
  refuel()
  print("Fuel status: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())

  local rowLength = Q_config.get("rowLength")
  local numRows = Q_config.get("numRows")
  print(rowLength, numRows)
  local fuelPer2Layers = rowLength * numRows * 4

  if turtle.getFuelLevel() < fuelPer2Layers then
    print("Fuel level is too low ("..turtle.getFuelLevel().."/"..fuelPer2Layers..")!")
    print("Please, refuel the turtle in order to begin the process.")
    pause("Press any key to return to menu")
    return
  end

  -- Layout 1 -> R,L,R,L...X
  -- Layout 2 -> L,R,L,R...X
  local nextRow = true
  local lastRow = numRows

  while true do
    -- TODO If the inventory won't be able to hold anymuch, return to base and empty inventory.
    -- TODO Manage inventory and time either per percent or per 2 layers.
    -- Return to base if:
    -- Will not be able to come back after the next two diggings or does not have enough fuel to continue.
    -- TODO Add refuel system in the base and return to resumeYLocation.
    -- TODO Store in config depth reached in order to continue later.

    curFuelLevel = turtle.getFuelLevel()
    curYLocation = Q_config.get("curYLocation") < 0 and Q_config.get("curYLocation") * -1 or Q_config.get("curYLocation")

    if curFuelLevel < Q_config.get("startYLocation") - curYLocation + 4
        or turtle.getFuelLevel() < fuelPer2Layers
        or isInventoryFull() then
      Q_Config.set("resumeYLocation", curYLocation)
      -- config["resumeYLocation"] = curYLocation
      return2Base()

      if isInventoryFull() then
        print("The inventory is full to continue")
      else
        print("Fuel level is too low to continue ("..curFuelLevel.."/"..fuelPer2Layers..")!")
      end

      emtpyInventory()
      refuel()

      -- TODO Control if has gained any energy and if not finish the quarry process.
      resume()

    -- Has reached its maximum depth or is near to.
    elseif Q_config.get("curYLocation") - 4 < Q_config.get("maxDepth") then
      return2Base()
      pause("The quarry has reached the maximum depth")
      return

    end

    digLayer(true, rowLength, numRows)
    digLayer(false, rowLength, numRows)

    ::continue::
  end
end

function printConfig()
  Q_config.print()
  pause("Press enter to continue...")
end

function menu()
  term.clear()
  print("Select an option:")
  print("1. Start quarry")
  print("2. Edit config")
  print("3. Print config")
  print("(Nothing for exit)")
  write("> ")
  return read()
end

function editConfig()
  local input = nil
  local input_key = nil
  local input_value = nil

  while true do
    term.clear()
    Q_config.print()
    write("Enter key> ")
    input_key = read()
    if input_key == "" then break end

    if Q_config.exists(input_key) then
      write("Set the new value [".. Q_config.get(input_key) .."]: ")
      input_value = read()
      if input_value ~= "" then
        Q_config.set(input_key, tonumber(input_value))
      end
    else
      write("That key does not exist, do you want to add it? Y/N: ")
      if string.lower(read()) == "y" then
        write("Set a value for the new key: ")
        input_value = read()
        if input_value ~= "" then
          Q_config.set(input_key, input_value)
        end
      end
    end
  end

  Q_config.save()
end

function main()
  Q_config.load()

  config = Q_config.getConfig()

  while true do
    local option = menu()

    if option == "" then
      break
    elseif option == "1" then
      if Q_config.isset then
        quarry()
      else
        pause("Quarry cannot start until config is set.")
      end
    elseif option == "2" then
      editConfig()
    elseif option == "3" then
      if Q_config.isset then
        term.clear()
        Q_config.print()
        pause()
      else
        pause("Config cannot be printed until config is set.")
      end
    end
  end

  Q_config.save()

end

main()
