
--[[ CONFIG ]]--
config = {
  ["yLocation"] = nil,
  ["rowLength"] = 3,
  ["numRows"] = 2
}
isConfigSet = false
--[[configPath = "/disk/quarry.cfg"

--- Load the configuration from quarry.cfg
-- If there is no file named quarry.cfg, the default config
-- will be both written and used.
-- Otherwise, the config of the file will be used for the program.
function loadConfig()
  local fd = open(configPath, "r")
  local line = fd.readLine()
  while line do
    line = line:gsub("%s+", "") -- Remove spaces
    key, value = ssplit(line, "=")
    config[key] = tonumber(value)
  end
  fd.close()
end

function writeConfig()
  local fd = open(configPath, "w")
  for key, value in ipairs(config) do
    fd.writeLine(key .. "=" .. tostring(value) .. "\n")
  end
  fd.close()
end

function editConfig()
  local input = ""

  for key, value in ipairs(config) do
    ::userinput::
    write(key.."("..tostring(value).."): ")
    input = read():gsub("%s+", "")

    if input == "" then
      print("")
    end

    if key == "yLocation" then
      if input != "" then
        config[key] = tonumber()
    if input == "" then
      if key == "rowLenght" or key == "numRows") then
        print("Input cannot be empty for '"..key.."'")
        goto userinput
      end
    elseif key == "numRows" and tonumber(input) % 2 != 0 then
      print("'numRows' cannot be odd")
      goto userinput
    end

    config[key]
  end
end]]--

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
  while turtle.getFuelLevel() < turtle.getFuelLimit() do
    turtle.suckUp()
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

function menu()
  term.clear()
  print("Select an option:")
  print("1. Start quarry")
  print("2. Set quarry size")
  print("3. Print config")
  print("(Nothing for exit)")
  write("> ")
  return read()
end

function setConfig()
  term.clear()
  write("yLocation: ")
  config["startYLocation"] = tonumber(read())
  config["curYLocation"] = config["startYLocation"]
  -- write("maxDepth [-59]: ")
  -- config["maxDepth"] = tonumber(read())
  config["maxDepth"] = -59
  write("Row length [2]: ")
  config["rowLength"] = tonumber(read())
  write("Number of rows (must be even) [2]: ")
  config["numRows"] = tonumber(read())
  isConfigSet = true
end

function printConfig()
  term.clear()
  for key, value in pairs(config) do
    print(key.." = "..value)
  end
  pause("Press any key to continue...")
end

function main()
  while true do
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
      setConfig()
    elseif option == "3" then
      if isConfigSet then
        printConfig()
      else
        pause("Config cannot be printed until config is set.")
      end
    end
  end
end

main()
