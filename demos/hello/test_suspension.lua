require "suspension"
require "hello"

local IDL_HOME = os.getenv("IDL_PATH")

-- carga das IDLs no ORB
orb:loadidlfile(IDL_HOME .. "scs.idl")
orb:loadidlfile(IDL_HOME .. "hello.idl")

-- função main
oil.main(function()
  -- Instrução ao ORB para que aguarde por chamadas remotas (em uma nova "thread")
  oil.newthread(orb.run, orb)

  -- Sets the Suspender class as the interceptor
  orb:setserverinterceptor(Suspender)
  --orb:setclientinterceptor(Suspender)

  -- Cria o componente e escreve sua configuração IOR no próprio diretório
  local instance = scs.newComponent(facetDescs, receptDescs, cpId, orb)
  if (instance == nil) then print ("nil hello instance") end
  oil.writeto("hello.ior", orb:tostring(instance.Hello))
  local iHelloIOR = oil.readfrom("hello.ior")
  if (iHelloIOR == nil) then print("Error while reading IOR file") else print ("Read IOR file") end

  -- obtenção das facetas IHello e IComponent
  local iHelloFacet = orb:newproxy(iHelloIOR, "IDL:scs/demos/helloworld/Hello:1.0")
  -- precisamos utilizar o método narrow pois estamos recebendo um org.omg.CORBA. Object
  --local icFacet = orb:narrow(iHelloFacet:_component())

  -- inicialização do componente
  --icFacet:startup()
  --print(icFacet)

  print("Saying hello")
  iHelloFacet:sayHello("hello")
  iHelloFacet:sayHello("my")
  iHelloFacet:sayHello("cannabis")
  iHelloFacet:sayHello("broder")
end)

