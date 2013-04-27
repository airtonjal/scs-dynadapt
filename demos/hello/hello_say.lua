local oil = require "oil"
local orb = oil.init()

local IDL_HOME = os.getenv("IDL_PATH")

-- carga das IDLs no ORB
orb:loadidlfile(IDL_HOME .. "scs.idl")
orb:loadidlfile(IDL_HOME .. "hello.idl")
orb:loadidlfile(IDL_HOME .. "composite.idl")
orb:loadidlfile(IDL_HOME .. "lifecycle.idl")

local HELLO_IDL_NAME = "IDL:scs/demos/helloworld/IHello:1.0"
local ICOMPONENT_IDL_NAME = "IDL:scs/core/IComponent:1.0"
local IMETA_IDL_NAME = "IDL:scs/core/IMetaInterface:1.0"
local ILIFECYCLE_IDL_NAME = "IDL:scs/core/lifecycle/ILifeCycle:1.0"
local iHello = "IHello"

arg[1] = arg[1] or ""
oil.verbose:level(0)

-- função main
oil.main(function()

  -- Cria o componente e escreve sua configuração IOR no próprio diretório
  --local helloIOR = oil.readfrom("hello.ior")
  --if (not helloIOR) then print("|----- ERROR -----|   Error while reading IOR file") os.exit(0) else print ("|----- OK ------|   IOR file succesfully read") end
  --print("Pure IOR: " .. helloIOR)
  --orb.tostring(helloIOR)
  
  --local helloComponent = orb:newproxy(helloIOR)
  --local helloComponent = orb:newproxy("corbaloc:iiop:127.0.0.1:1081/" .. ICOMPONENT_IDL_NAME, "protected", ICOMPONENT_IDL_NAME)
  local helloComponent = orb:newproxy("corbaloc:iiop:127.0.0.1:1081/Hello", nil, ICOMPONENT_IDL_NAME)
   
  if (helloComponent) then
    helloComponent = orb:narrow(helloComponent, ICOMPONENT_IDL_NAME)
    --if (helloComponent) then print("Could bind to IComponent interface") else print("Could not bind to IComponent interface") return end

    --print("Getting facet " .. HELLO_IDL_NAME)
    local iHelloFacet = helloComponent:getFacetByName(iHello)
    
    --local iHelloFacet = helloComponent:getFacetByName("IHello")
    local iHelloFacet = helloComponent:getFacet(HELLO_IDL_NAME)
    iHelloFacet = orb:narrow(iHelloFacet, HELLO_IDL_NAME)
    
    if (iHelloFacet) then
      iHelloFacet:sayHello("Hello my remote friend " .. arg[1])
    else
      error("Could not get IHelloFacet interface")
    end
  else 
    print("|----- ERROR -----| helloComponent object is not valid")
  end
end)


