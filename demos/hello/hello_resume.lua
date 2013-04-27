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
  if (helloIOR == nil) then print("|----- ERROR -----|   Error while reading IOR file") end
  
  -- obtenção das facetas IHello e IComponent
  --local iHelloFacet = orb:newproxy(helloIOR, HELLO_IDL_NAME)
  
  -- precisamos utilizar o método narrow pois estamos recebendo um org.omg.CORBA. Object
  local helloComponent = orb:newproxy(helloIOR)
  if (helloComponent) then
    -- Binds to iComponent in order to acquire the facets
    helloComponent = orb:narrow(helloComponent, ICOMPONENT_IDL_NAME)

    local iLifeCycleFacet = helloComponent:getFacetByName("ILifeCycle")
    iLifeCycleFacet = orb:narrow(iLifeCycleFacet, ILIFECYCLE_IDL_NAME)
    
    if (iLifeCycleFacet) then
      iLifeCycleFacet:changeState("RESUMED")
    else
      error("Could not get ILifeCycle interface")
    end
  else 
    print("|----- ERROR -----| helloComponent object is not valid")
  end
end)

