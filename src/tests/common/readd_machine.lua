local adlLocation = arg[1]

local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"
require (adlLocation)
--require "scs.core.table_print"


local ip = getIP()
local filename = debug.getinfo(1).source

local orb = getORB(oil)

local scs          = require "scs.core.base"
local scsAdaptive  = require "scs.core.adaptive"
--local scsComposite = require "scs.core.composite"

local IDL_HOME = os.getenv("IDL_PATH")
loadIDL(IDL_HOME, orb)

oil.main(function()
  --local corbaloc = "corbaloc:iiop:127.0.0.1:" .. DEFAULT_ORB_PORT .. "/ArchIComponent"
  local CORBALOC = corbaloc( ip, DEFAULT_ORB_PORT, ARCH_MANAGER_ICOMPONENT_KEY )
  local archManagerComponent = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)

  if (archManagerComponent) then
    --print("Succesfully acquired IComponent interface from ArchManager")
    archManagerComponent = orb:narrow(archManagerComponent, IDL_ICOMPONENT)
    
    local iArchManagerFacet = archManagerComponent:getFacetByName( ARCH_MANAGER_FACET_NAME )
    iArchManagerFacet = orb:narrow(iArchManagerFacet, IDL_ARCH_MANAGER)

    if (iArchManagerFacet) then
      local started = iArchManagerFacet:isStarted()
      local addedMachines = iArchManagerFacet:getMachines()
      --print("We have " .. #addedMachines .. " machines already added")
      assert(#addedMachines > 0)
      local status, ret = oil.pcall(iArchManagerFacet.addMachine, iArchManagerFacet, addedMachines[1])
      if (status) then
        error("System was started and readadd_machine did not throw exception " .. MACHINE_ALREADY_EXISTS_EX)
      elseif (not status and ret[1] == MACHINE_ALREADY_EXISTS_EX) then
        print(filename .. " OK")
      else
        error("Exception caught should have been " .. MACHINE_ALREADY_EXISTS_EX .. " but instead we got " .. ret[1])
      end
    else
      error("Could not get IArchManager interface")
    end
      --iArchManagerFacet:startSystem( { system_name = "testing" } )
  else
    error("Could not acquire IComponent interface from ArchManager component. Corbaloc: " .. corbaloc)
  end
end)

