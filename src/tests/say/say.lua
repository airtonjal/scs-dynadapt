local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "utils.HelloUtils"

local Sayer = oo.class{
  name = "Sayer",
  receptacles = {}
}

function Sayer:sayHello()
  local orb = oil.orb
  
  -- Here the component can assume that it is already connected to its dependencies
  local meta = self.context[IMETA_NAME]
  local receps = meta:getReceptacles()
  local hello = nil
  for k,v in ipairs(receps) do
    if (v.name == HELLO_FACET_NAME) then
      hello = v.connections[1].objref
      break
    end
  end
  
  hello = orb:narrow(hello, IDL_IHELLO)

  local lifeCycle = self.context[ILIFECYCLE_NAME]
  lifeCycle:changeState(RESUMED)
  local count = 0
  while(lifeCycle:getState() ~= RESUMED) do oil.sleep(1) end
    --print(lifeCycle:getState())
    while(lifeCycle:getState() == RESUMED) do
    count = count + 1
    hello:sayHello("Hello my remote friend! Saying hello for the " .. tostring(count) .. " time")
    oil.sleep(0.2)
  end
  print("Finished saying hello")
end

local jump = function() print("\n|X| ----------------------------------------------------------------- |X|\n") end
function Sayer:startup()  
  jump() print("\t\t\tSAYER COMPONENT FIRING UP")
  oil.newthread(Sayer.sayHello, self)
  jump() 
end

function Sayer:shutdown()
  jump() print ("\t\t\tSAYER COMPONENT SHUTTING DOWN")
  local lifeCycle = self.context[ILIFECYCLE_NAME]
  lifeCycle:changeState(HALTED)
--  for k, v in pairs(self.context) do print(k,v) end
--  self.context[IRECEP_NAME]
  if (oil.orb) then
    for name, facet in pairs(self.context._facetDescs) do
      print("Deactivating " .. tostring(name))
      oil.orb:deactivate(facet.facet_ref)
    end
  end
  jump()
end

return { receptacles = Sayer.receptacles, startup = Sayer.startup, shutdown = Sayer.shutdown  }

