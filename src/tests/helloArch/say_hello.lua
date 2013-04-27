local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"
require "utils.HelloUtils"
require "utils.machines"

local ip = getIP()
local hostname = getHostName()
local filename = debug.getinfo(1).source

local orb = getORB(oil)

local IDL_HOME = os.getenv("IDL_PATH")
loadIDL(IDL_HOME, orb)

-- função main
oil.main(function()
  local CORBALOC = corbaloc( machines.ubuntu2.host, DEFAULT_ORB_PORT, "HelloComponent" )

  local helloComponent = orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)
   
  if (helloComponent) then
    helloComponent = orb:narrow(helloComponent, IDL_ICOMPONENT)
    local iHelloFacet = helloComponent:getFacetByName(HELLO_FACET_NAME)
    
    --local iHelloFacet = helloComponent:getFacet(HELLO_FACET_NAME)
    iHelloFacet = orb:narrow(iHelloFacet, IDL_IHELLO)
    
    if (iHelloFacet) then
      iHelloFacet:sayHello("Hello my remote friend. I'm saying hello from host " .. hostname .. " and file " .. filename)
    else
      error("Could not get IHelloFacet interface")
    end
  else 
    print("|----- ERROR -----| helloComponent object is not valid")
  end
end)


