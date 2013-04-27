require "adl"
local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"
require "adl"

local ip = getIP()

if (not oil.orb) then
  print("Starting orb on check_deployer.lua\tIP: " .. ip .. "\tPort: " .. DEFAULT_ORB_PORT)
  oil.orb = oil.init({host = getIP(), port = DEFAULT_ORB_PORT, flavor = "cooperative;corba.intercepted"})
else
  print("Orb is started already")
end
local orb = oil.orb

local scs          = require "scs.core.base"
local scsAdaptive  = require "scs.core.adaptive"
--local scsComposite = require "scs.core.composite"

local IDL_HOME = os.getenv("IDL_PATH")
-- carga das IDLs no ORB
orb:loadidlfile(IDL_HOME .. "scs.idl")
orb:loadidlfile(IDL_HOME .. "composite.idl" )
orb:loadidlfile(IDL_HOME .. "lifecycle.idl" )
orb:loadidlfile(IDL_HOME .. "arch.idl" )
orb:loadidlfile(IDL_HOME .. "deployer.idl" )

--local corbaloc = "corbaloc:iiop:" .. ip .. ":" .. DEFAULT_ORB_PORT ..  "/Deployer"
print(DEPLOYER_ICOMPONENT_KEY)
print(IDL_ICOMPONENT)
print(DEPLOYER_FACET_NAME)
local CORBALOC = corbaloc( "192.168.58.130", DEFAULT_ORB_PORT, DEPLOYER_ICOMPONENT_KEY )
print(CORBALOC)
local deployer = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)
print("isProxyNonExistent: " .. booleanString(isProxyNonExistent(deployer)))

oil.main(function()
  print("is_a: "  .. booleanString(is(deployer, IDL_ICOMPONENT)))
  if (deployer and not isProxyNonExistent(deployer) and is(deployer, IDL_ICOMPONENT) ) then
    print("deployer object exists and is of type " .. IDL_ICOMPONENT .. "\tNARROWING")
    deployer = orb:narrow(deployer, IDL_ICOMPONENT)
    --table_print(deployer)
    --print(deployer.startup)
    --print(deployer.getComponentId)
    --local id = deployer:getComponentId()
    --print(id.name)
    --print(id.platform_spec)
    --deployer:startup()

    local iDeployer = deployer:getFacetByName( DEPLOYER_FACET_NAME )
    --[[local meta = deployer:getFacetByName( IMETA_NAME )
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
    if (status) then print "OK HERE TOO TOO"
    else 
      print ("DEU MERDA PAPAI " .. facets[1]) 
      --for k, v in ipairs(facets) do print (k, v) end
      --table_print(facets)
    end
    --for k,v in pairs(facets) do print(v.interface_name) end]]--


    if (iDeployer) then
      if (isProxyNonExistent(iDeployer)) then print "NON EXISTENT" else print "EXISTENT" end
      if (not is(iDeployer, IDL_DEPLOYER)) then print "IS NOT DEPLOYER" else print "IS DEPLOYER" end
      print ("BEFOREEEEEEEEEEEEEEEEEEEEE")
      iDeployer = orb:narrow(iDeployer, IDL_DEPLOYER)
      print ("AFTERRRRRRRRRRRRRRRRRRRRRRR")
      local started = iDeployer:isAvailable()
      if (started) then print ("Deployer is started") else print ("Deployer is not started") end
    else
      error("Could not get IDeployer interface")
    end
  else
    error("Could not acquire IComponent interface from Deployer component. Corbaloc: " .. CORBALOC)
  end
end)

