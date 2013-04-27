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
  local CORBALOC = corbaloc( ip, DEFAULT_ORB_PORT, ARCH_MANAGER_ICOMPONENT_KEY )
  --local corbaloc = "corbaloc:iiop:127.0.0.1:" .. DEFAULT_ORB_PORT .. "/ArchIComponent"
  local archManagerComponent = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)

  if (archManagerComponent) then
    archManagerComponent = orb:narrow(archManagerComponent, IDL_ICOMPONENT)
    local archFacet = archManagerComponent:getFacetByName(ARCH_MANAGER_FACET_NAME)
    archFacet = orb:narrow(archFacet, IDL_ARCH_MANAGER)

    if (archManagerComponent) then
      local status, result = oil.pcall(archFacet.toStringArch, archFacet)
      if (status) then 
        print(result)
        print(filename .. " OK")
      else 
        error(filename .. " Exception was thrown: " .. ret[1])
      end
    else
      error("Could not print ArchManager architecture with arch:toStringArch interface")
    end
  else
    error("Could not acquire IComponent interface from ArchManager")
  end
end)

