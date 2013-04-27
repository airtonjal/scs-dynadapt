local oo = require "loop.base"
local oil = require "oil"
require "scs.core.arch.utils.ArchUtils"
require "utils.HelloUtils"

local Filter = oo.class{
  name = "Filter",
  receptacles = {}
}

function Filter:sayHello(str)
  local orb = oil.orb

  -- Apply filter
  if (not self:shouldGo(str)) then return end

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

  -- Simply forwards the call
  hello = orb:narrow(hello, IDL_IHELLO)
  hello:sayHello(str)
end

-- Filters strings which have a even number
function Filter:shouldGo(str)
  if (not str or str:find("1") or str:find("3") or str:find("5") or str:find("7") or str:find("9")) then
    return false
  else
    return true
  end
end

local jump = function() print("\n|X| ----------------------------------------------------------------- |X|\n") end
function Filter:startup()
  jump() print("\t\t\tFILTER COMPONENT FIRING UP")
  oil.newthread(Filter.sayHello, self)
  jump()
end

function Filter:shutdown()
  jump() print ("\t\t\tFILTER COMPONENT SHUTTING DOWN")
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

return { [HELLO_FACET_NAME] = Filter , startup = Filter.startup, shutdown = Filter.shutdown  }

