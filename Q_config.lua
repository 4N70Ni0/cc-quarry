Q_config = {}

Q_config.values = {
  ["yLocation"] = nil,
  ["rowLength"] = 3,
  ["numRows"] = 2
}
Q_config.isset = false
Q_config.configPath = "/quarry/quarry.cfg"

function ssplit(str, char)
  local occur = string.find(str, char)
  -- KEY, VALUE
  return string.sub(str, 1, occur - 1), string.sub(str, occur + 1)
end

--- Load the configuration from quarry.cfg
-- If there is no file named quarry.cfg, the default config
-- will be both written and used.
-- Otherwise, the config of the file will be used for the program.
function Q_config.load()
  Q_config.isset = true

  local fd = fs.open(Q_config.configPath, "r")
  while true do
    local line = fd.readLine()
    if not line then break end
    line = line:gsub("%s+", "") -- Remove spaces

    if string.sub(line, 1, 1) ~= "#" then
      key, value = ssplit(line, "=")
      Q_config.values[key] = value
    end
  end
  fd.close()

end

function Q_config.save()
  local fd = fs.open(Q_config.configPath, "w")
  for key, value in ipairs(Q_config.values) do
    fd.writeLine(key .. "=" .. tostring(value) .. "\n")
  end
  fd.close()
end

-- function Q_config.edit()
--   local input = ""

--   for key, value in ipairs(config) do
--     ::userinput::
--     write(key.."("..tostring(value).."): ")
--     input = read():gsub("%s+", "")

--     if input == "" then
--       print("")
--     end

--     if key == "yLocation" then
--       if input ~= "" then
--         config[key] = tonumber()
--     if input == "" then
--       if key == "rowLenght" or key == "numRows" then
--         print("Input cannot be empty for '"..key.."'")
--         goto userinput
--       end
--     elseif key == "numRows" and tonumber(input) % 2 ~= 0 then
--       print("'numRows' cannot be odd")
--       goto userinput
--     end

--     --config[key]
--   end
-- end

function Q_config.set(key, value)
    Q_config.values[key] = value
  -- term.clear()
  -- write("yLocation: ")
  -- config["startYLocation"] = tonumber(read())
  -- config["curYLocation"] = config["startYLocation"]
  -- -- write("maxDepth [-59]: ")
  -- -- config["maxDepth"] = tonumber(read())
  -- config["maxDepth"] = -59
  -- write("Row length [2]: ")
  -- config["rowLength"] = tonumber(read())
  -- write("Number of rows (must be even) [2]: ")
  -- config["numRows"] = tonumber(read())
  -- isConfigSet = true
end

function Q_config.get(key)
  return Q_config.values[key]
end

function Q_config.print()
  term.clear()
  for key, value in pairs(config) do
    print(key.." = "..value)
  end
  pause("Press any key to continue...")
end

function Q_config.get()
  return Q_config.values
end

return Q_config
