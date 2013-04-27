local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
orb = oil.init()

local IDL_HOME = os.getenv("IDL_PATH")

function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  for filename in popen('ls -a "'..directory..'"'):lines() do
    i = i + 1
    t[i] = filename
  end
  return t
end

local files = scandir(IDL_HOME)

for _, filename in ipairs(files) do
  local length = #filename
  if (length >= 4) then
    local sub = filename:sub ( length - 2 )
    if ( sub == "idl" ) then
      print("Loading " .. IDL_HOME .. filename)
      orb:loadidlfile(IDL_HOME .. filename)
    else
      print("\"" .. filename .. "\" is not a idl file\tignoring...")
    end
  else
    print("\"" .. filename .. "\" is not a idl file\tignoring...")
  end
end




