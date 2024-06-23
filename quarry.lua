
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
end

function quarry()
  local fuelPer2Layers = rowLength * numRows * 2
  if turtle.getFuelLevel() < fuelPer2Layers then
    print("Fuel level is too low ("..turtle.getFuelLevel().."/"..fuelPer2Layers..")!")
    print("Please, refuel the turtle in order to begin the process.")
    pause("Press any key to return to menu")
    return
  end

  rowLength = config["rowLength"]
  numRows = config["numRows"]

  -- Layout 1 -> R,L,R,L...X
  -- Layout 2 -> L,R,L,R...X
  local nextRow = true
  local lastRow = numRows

  while true do
    digLayer(true, rowLength, numRows)
    digLayer(false, rowLength, numRows)

    if turtle.getFuelLevel() < fuelPer2Layers then
      print("Fuel level is too low to continue ("..turtle.getFuelLevel().."/"..fuelPer2Layers..")!")
      print("Please, refuel the turtle in order to begin the process.")
      pause("Press any key to return to menu")
      return
    end
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
  config["yLocation"] = tonumber(read())
  write("maxDepth [-59]: ")
  config["maxDepth"] = tonumber(read())
  write("Row length [2]: ")
  config["rowLength"] = tonumber(read())
  write("Number of rows (must be even) [2]: ")
  config["numRows"] = tonumber(read())
end

function printConfig()
  term.clear()
  for key, value in pairs(config) do
    print(key.." = "..value)
  end
  print("Press any key to continue...")
  read()
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
