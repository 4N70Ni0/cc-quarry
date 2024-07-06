Q_config = {}

Q_config.values = {}
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

    if line ~= "" then
      line = line:gsub("%s+", "") -- Remove spaces
      if string.sub(line, 1, 1) ~= "#" then
        key, value = ssplit(line, "=")
        Q_config.values[key] = tonumber(value)
      end
    end
  end
  fd.close()
end

function Q_config.save()
  local fd = fs.open(Q_config.configPath, "w")
  for key, value in pairs(Q_config.values) do
    fd.writeLine(key .. "=" .. tostring(value))
  end
  fd.close()
end

function Q_config.set(key, value)
    Q_config.values[key] = value
end

function Q_config.get(key)
  if Q_config.values[key] == nil then
    return false
  end
  return Q_config.values[key]
end

function Q_config.getConfig()
  return Q_config.values
end

--- Returns true or false whether a key exists in config.
function Q_config.exists(key)
  return Q_config.values[key] ~= nil
end

function Q_config.print()
  for key, value in pairs(Q_config.values) do
    print(key.." = "..value)
  end
end

return Q_config
