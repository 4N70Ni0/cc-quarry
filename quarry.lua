local Q_config = require("Q_config")


function pause(msg)
  write(msg)
  read()
end

--[[ TURTLE ]]--

function cleanRow(length)
  for block = 1, length do
    if turtle.detectDown() then
      turtle.digDown()
    end
    if block <= length - 1 then
      turtle.forward()
    end
  end
end

function turnRight()
  turtle.turnRight()
  turtle.forward()
  turtle.turnRight()
end

function turnLeft()
  turtle.turnLeft()
  turtle.forward()
  turtle.turnLeft()
end

function return2Base()
  while config["curYLocation"] < config["startYLocation"] do
    turtle.up()
    config["curYLocation"] = config["curYLocation"] + 1
  end
end

function digLayer(layout, rowLength, numRows)
  -- Forward (TRUE) -> R,L,R,L...X
  -- Backwards (FALSE) -> L,R,L,R...X
  local nextRow = layout
  local lastRow = numRows

  for row = 1, lastRow do
    cleanRow(rowLength)

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
  config["curYLocation"] = config["curYLocation"] - 1
end

--- Emtpy inventory into the behind chest.
function emtpyInventory()
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
  while config["curYLocation"] > config["resumeYLocation"] do
    turtle.down()
    config["curYLocation"] = config["curYLocation"] - 1
  end
end

function quarry()
  emtpyInventory()
  refuel()
  print("Fuel status: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())

  local rowLength = config["rowLength"]
  local numRows = config["numRows"]
  local fuelPer2Layers = rowLength * numRows * 2

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
    curYLocation = config["curYLocation"] < 0 and config["curYLocation"] * -1 or config["curYLocation"]

    if curFuelLevel < config["startYLocation"] - curYLocation + 2 or turtle.getFuelLevel() < fuelPer2Layers then
      config["resumeYLocation"] = curYLocation
      return2Base()
      print("Fuel level is too low to continue ("..curFuelLevel.."/"..fuelPer2Layers..")!")

      emtpyInventory()
      refuel()

      -- TODO Control if has gained any energy and if not finish the quarry process.

      resume()

    -- Has reached its maximum depth or is near to.
    elseif config["curYLocation"] - 2 < config["maxDepth"] then
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

-- Make an interpreter where each time a key is edited, prints all values again
-- let the user input the key (tell them if exists or not) and tell them the
-- value of that key and let them change it and save the config at the end.
function editConfig()
  local input = nil
  local input_key = nil
  local input_value = nil

  while true do
    -- term.clear()
    Q_config.print()
    write("> ")
    input_key = read()
    if input_key == "" then break end

    if Q_config.exists(input) then
      write("Set the new value [".. Q_config.get(input) .."]: ")
      input_value = read()
      Q_config.set(input_key, tonumber(input_value))
    else
      write("That key does not exist, do you want to add it? Y/N: ")
      if string.lower(read()) == "y" then
        write("Set a value for the new key: ")
        input_value = read()
        Q_config.set(input_key, input_value)
      end
    end
  end

  Q_config.save()
end

function main()

  -- TODO Fix why config is not being loaded from file
  -- and then fix the edit config function because it's
  -- not finding the keys in the dict idk.
  Q_config.load()
  Q_config.print()

  print("begin ---")
  for k,v in ipairs(Q_config.values) do
    print(k.." = "..v)
  end
  print("--- end")


  while false do
    local option = menu()

    if option == "" then
      break
    elseif option == "1" then
      if isConfigSet then
        quarry()
      else
        pause("Quarry cannot start until config is set.")
      end
    elseif option == "2" then
      editConfig()
    elseif option == "3" then
      if isConfigSet then
        printConfig()
      else
        pause("Config cannot be printed until config is set.")
      end
    end
  end

  -- Q_config.save()

end

main()
