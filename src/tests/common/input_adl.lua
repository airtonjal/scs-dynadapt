require (arg[1])

local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"
local utils = require "scs.core.utils"
utils = utils.Utils()

local ip = getIP()
local filename = debug.getinfo(1).source

local orb = getORB(oil)

local scs          = require "scs.core.base"
local scsAdaptive  = require "scs.core.adaptive"
--local scsComposite = require "scs.core.composite"

local IDL_HOME = os.getenv("IDL_PATH")
-- carga das IDLs no ORB
loadIDL(IDL_HOME, orb)

oil.main(function()
  local CORBALOC = corbaloc( ip, DEFAULT_ORB_PORT, ARCH_MANAGER_ICOMPONENT_KEY )
  local archComponent = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)

  if (archComponent) then
    archComponent = orb:narrow(archComponent, IDL_ICOMPONENT)
    
    local archFacet = archComponent:getFacetByName( ARCH_MANAGER_FACET_NAME )
    archFacet = orb:narrow(archFacet, IDL_ARCH_MANAGER)

    if (archFacet) then
      local started = archFacet:isStarted()
      local status, ret = oil.pcall(archFacet.startSystem, archFacet, ADL )
      if (not started and not status) then
        error("Could not start ArchManager system!! Exception thrown " .. ret[1])
      elseif (not status and started and not ret[1] == ALREADY_STARTED_EX) then
        error("Exception " .. ALREADY_STARTED_EX .. " should have been thrown! System is already started") 
      else
        print(filename .. " OK") 
      end
    else
      error("Could not get IArchManager interface")
    end
  else
    error("Could not acquire IComponent interface from ArchManager component. Corbaloc: " .. CORBALOC)
  end
end)

