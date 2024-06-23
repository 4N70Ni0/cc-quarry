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

function quarry(rowLength, numRows)
  -- Layout 1 -> R,L,R,L...X
  -- Layout 2 -> L,R,L,R...X
  local nextRow = true
  local lastRow = numRows

  while true do
    digLayer(true, rowLength, numRows)
    digLayer(false, rowLength, numRows)
  end
end

function loadConfig(configPath)
  if configPath == "" then
    configPath = "/disk/quarry.cfg"
  end

  -- If there is not a cfg file, returns a default config.
  if not fs.exists(configpath) then
    return {
      "yLocation": nil,
      "rowLength": 2,
      "numRows": 2,
    }
  end

  local key = ""
  local value = ""
  local config = {}
  local fd = open(configPath, "r")
  local line = fd.readLine()
  while line do
    key, value = ssplit(line, "=")
    config[key] = tonumber(value)
  end
  fd.close()

  return config
end

-- function writeConfig(configPath, )

function main()
  term.clear()
  print("Select an option:")
  print("1. Edit config")

end

main()
