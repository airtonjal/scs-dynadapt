local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"
require (arg[1])

local ARCH_HOME = os.getenv("ARCH_HOME")

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
  local CORBALOC = corbaloc( ip, DEFAULT_ORB_PORT, ARCH_MANAGER_KEY )
  local archFacet = orb:newproxy(CORBALOC, nil, IDL_ARCH_MANAGER)

  if (archFacet) then
    -- Binds to iComponent in order to acquire the facets
    archFacet = orb:narrow(archFacet, IDL_ARCH_MANAGER)

    if (archFacet) then
      --local status, result = oil.pcall(archManagerComponent.shutdownDeployers, archManagerComponent)
      local newImpl = io.open(ARCH_HOME .. "src/tests/helloReplace/newHello.lua", "r"):read("*a")

      local status = archFacet:replaceInstance( helloInstance.unique_name, newImpl )
      if (status) then 
        print(filename .. " OK")
      else 
        error("deployers.lua Exception was thrown: " .. result[1])
      end
    else
      error("Could not shutdown Deployers with IComponent:shutdown interface")
    end
  else
    error("Could not acquire IComponent interface from ArchManager")
  end
end)

