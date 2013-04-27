require "adl"
local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"
require "adl"

local ip = getIP()
local filename = debug.getinfo(1).source

local orb = getORB(oil)

local scs          = require "scs.core.base"
local scsAdaptive  = require "scs.core.adaptive"
--local scsComposite = require "scs.core.composite"

local IDL_HOME = os.getenv("IDL_PATH")
loadIDL(IDL_HOME, orb)

--local corbaloc = "corbaloc:iiop:" .. ip .. ":" .. DEFAULT_ORB_PORT ..  "/Deployer"
print(DEPLOYER_ICOMPONENT_KEY)
print(IDL_ICOMPONENT)
print(DEPLOYER_FACET_NAME)
local CORBALOC = corbaloc( "192.168.58.130", DEFAULT_ORB_PORT, ARCH_MANAGER_ICOMPONENT_KEY )
print(CORBALOC)
local arch = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)
print("isProxyNonExistent: " .. booleanString(isProxyNonExistent(arch)))

oil.main(function()
  print("is_a: "  .. booleanString(is(arch, IDL_ICOMPONENT)))
  if (arch and not isProxyNonExistent(arch) and is(arch, IDL_ICOMPONENT) ) then
    print("arch object exists and is of type " .. IDL_ICOMPONENT .. "\tNARROWING")
    arch = orb:narrow(arch, IDL_ICOMPONENT)

    --local iDeployer = arch:getFacetByName( "Deployer" )
    local meta = arch:getFacetByName( IMETA_NAME )
    if (meta) then print "OK HERE" end
    if (isProxyNonExistent(meta)) then print("META NOT EXISTENT") else print ("META EXISTENT") end
    if (is(meta, IDL_IMETA)) then print("META IS") else print ("META IS NOT ") end
    --table_print(meta)
    meta = orb:narrow(meta, IDL_IMETA)
    if (meta) then print "OK HERE TOO" end
    meta:getFacets()
    --oil.sleep(2)
    --local facets = meta:getFacets()
    local status, facets = oil.pcall(meta.getFacets, meta)
    if (status) then 
      print "Facets acquired"
      table_print(facets)
    else 
      print ("Arch component not found " .. facets[1]) 
    end
  else
    error("Could not acquire IComponent interface from Deployer component. Corbaloc: " .. CORBALOC)
  end
end)

