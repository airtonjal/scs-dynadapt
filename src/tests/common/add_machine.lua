local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"
require "utils.machines"
--require (adlLocation)

local ip = getIP()

local deployerMachine = nil
for k, v in pairs(machines) do
  if (v.host ~= ip) then 
    deployerMachine = k 
    break
  end
end
print("Deployer machine is " .. deployerMachine)

local filename = debug.getinfo(1).source

local orb = getORB(oil)

local scs          = require "scs.core.base"
local scsAdaptive  = require "scs.core.adaptive"

local IDL_HOME = os.getenv("IDL_PATH")
loadIDL(IDL_HOME, orb)

oil.main(function()
  local CORBALOC = corbaloc( ip, DEFAULT_ORB_PORT, ARCH_MANAGER_ICOMPONENT_KEY )
  local archManagerComponent = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)

  if (archManagerComponent) then
    archManagerComponent = orb:narrow(archManagerComponent, IDL_ICOMPONENT)
    
    local iArchManagerFacet = archManagerComponent:getFacetByName( ARCH_MANAGER_FACET_NAME )
    iArchManagerFacet = orb:narrow(iArchManagerFacet, IDL_ARCH_MANAGER)

    if (iArchManagerFacet) then
      local addedMachines = iArchManagerFacet:getMachines()
      assert(#addedMachines == 0)
      local status, ret = oil.pcall(iArchManagerFacet.addMachine, iArchManagerFacet, machines[deployerMachine])
      if (not status) then 
        print(deployerMachine, machines[deployerMachine])
      end
      if     (status) then
        local macs = iArchManagerFacet:getMachines()
        assert(#macs == #addedMachines + 1)
        print(filename .. " OK")
      elseif (not status) then
        error("Could not add machine: " .. ret[1]) 
      end
    else
      error("Could not get IArchManager interface")
    end
  else
    error("Could not acquire IComponent interface from ArchManager component. Corbaloc: " .. corbaloc)
  end
end)

