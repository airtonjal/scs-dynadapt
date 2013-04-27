local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"
--local suspender = require "suspension"

local ip = getIP()
local filename = debug.getinfo(1).source

local orb = getORB(oil)

local scs          = require "scs.core.base"
local scsAdaptive  = require "scs.core.adaptive"
--local scsComposite = require "scs.core.composite"

local IDL_HOME = os.getenv("IDL_PATH")
loadIDL(IDL_HOME, orb)

-- função main
oil.main(function()

  local CORBALOC = corbaloc(ip, DEFAULT_ORB_PORT, ARCH_MANAGER_ICOMPONENT_KEY)
  --local corbaloc = "corbaloc:iiop:127.0.0.1:" .. DEFAULT_ORB_PORT .. "/ArchIComponent"
  local archManagerComponent = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)

  if (archManagerComponent) then
    -- Binds to iComponent in order to acquire the facets
    archManagerComponent = orb:narrow(archManagerComponent, IDL_ICOMPONENT)

    if (archManagerComponent) then
      local status, ret = oil.pcall(archManagerComponent.startup, archManagerComponent)
      if (status) then 
        print(filename .. " OK")
      else 
        error("Exception was caught during IComponent:startup of ArchManager component. Exception: " .. ret[1])
      end
    else
      error("Could not start ArchManager with IComponent:startup interface")
    end
  else
    print("|----- ERROR -----| archManagerComponent object is not valid")
  end
end)

