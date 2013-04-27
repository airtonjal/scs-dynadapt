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

local IDL_HOME = os.getenv("IDL_PATH")
loadIDL(IDL_HOME, orb)

-- função main
oil.main(function()
  local CORBALOC = corbaloc( ip, DEFAULT_ORB_PORT, ARCH_MANAGER_ICOMPONENT_KEY )
  local archManagerComponent = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)

  if (archManagerComponent) then
    archManagerComponent = orb:narrow(archManagerComponent, IDL_ICOMPONENT)

    local archFacet = archManagerComponent:getFacetByName( ARCH_MANAGER_FACET_NAME )
    archFacet = orb:narrow(archFacet, IDL_ARCH_MANAGER)

    if (archFacet) then
      local status, ret = oil.pcall(archFacet.shutdownSystem, archFacet)
      if (status) then 
        print(filename .. " OK")
      else 
        error(filename .. " Exception was thrown: " .. ret[1])
      end
    else
      error("Could not shutdown system ArchManager:shutdownSystem interface")
    end
  else
    error("Could not acquire IComponent interface from ArchManager")
  end
end)

