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

-- função main
oil.main(function()

  -- Cria o componente e escreve sua configuração IOR no próprio diretório
  local helloIOR = oil.readfrom("hello.ior")
  if (helloIOR == nil) then print("|----- ERROR -----|   Error while reading IOR file") else print ("|----- OK ------|   IOR file succesfully read") end
  
  -- obtenção das facetas IHello e IComponent
  --local iHelloFacet = orb:newproxy(helloIOR, HELLO_IDL_NAME)
  
  -- precisamos utilizar o método narrow pois estamos recebendo um org.omg.CORBA. Object
  --local helloComponent = orb:newproxy(helloIOR)
  local helloComponent = orb:newproxy("corbaloc:iiop:127.0.0.1:1081/Hello", "protected", ICOMPONENT_IDL_NAME)
  if (helloComponent) then
    -- Binds to iComponent in order to acquire the facets
    helloComponent = orb:narrow(helloComponent, ICOMPONENT_IDL_NAME)
    --helloMeta      = orb:narrow(helloComponent, IMETA_IDL_NAME)
    --helloLifeCycle = orb:narrow(helloComponent, ILIFECYCLE_IDL_NAME)
    
    --local icFacet = orb:narrow(iHelloFacet:_component())
    --local facets = helloMeta:getFacets()
    --local iHelloFacet = helloComponent:getFacetByName(iHello)
    local iLifeCycleFacet = helloComponent:getFacetByName("ILifeCycle")
    iLifeCycleFacet = orb:narrow(iLifeCycleFacet, ILIFECYCLE_IDL_NAME)
    
    local iHelloFacet = helloComponent:getFacetByName("IHello")
    iHelloFacet = orb:narrow(iHelloFacet, HELLO_IDL_NAME)
    
    -- inicialização do componente
    --icFacet:startup()
    --print(icFacet)

    if (iLifeCycleFacet and iHelloFacet) then
      print("Saying hello: ")
      iHelloFacet:sayHello("Hello my remote friend")
      print("Getting state...")
      print(iLifeCycleFacet:getState())
      print("\nSuspending component...")
      --iLifeCycleFacet:changeState("RESUMED")
      --if (iLifeCycleFacet:changeState("SUSPENDED")) then print("Successfully changed to SUSPENDED, printing: ") end
--      print("Checking if lifecycle facet is blocked...")
--      print(iLifeCycleFacet:getState())
--      print("Trying to say hello again...")
      iHelloFacet:sayHello("Hello my remote friend 1!!")
      iHelloFacet:sayHello("Hello my remote friend 2!!")
      iHelloFacet:sayHello("Hello my remote friend 3!!")
      iHelloFacet:sayHello("Hello my remote friend 4!!")
      print("\nResuming back component...")
      
      if (iLifeCycleFacet:changeState("RESUMED")) then print("Successfully changed to RESUMED, printing: ") end
      print(iLifeCycleFacet:getState())
    else
      error("Could not get ILifeCycle interface")
    end
    --print("Saying hello")
    --iHelloFacet:sayHello("hello")
    --iHelloFacet:sayHello("my")
    --iHelloFacet:sayHello("cannabis")
    --iHelloFacet:sayHello("broder")
  else 
    print("|----- ERROR -----| helloComponent object is not valid")
  end
end)

