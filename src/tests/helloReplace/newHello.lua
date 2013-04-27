local oo = require "loop.base"
local oil = require "oil"
require "utils.HelloUtils"
require "scs.core.arch.utils.ArchUtils"
--local oil = require "oil"

 ------------------------------
--- NEW HELLO IMPLEMENTATION ---
 ------------------------------
local Hello = oo.class{name = "Hello World"}
function Hello:sayHello(str) 
  print("Before you say anything I say!! [[[ NEW IMPLEMENTATION ]]]\t"  .. tostring(str))
end

local jump = function() print("\n|X| ----------------------------------------------------------------- |X|\n") end
function Hello:startup()  jump() print("\t\t\tHELLO COMPONENT VERSION 2 FIRING UP")      jump() end
function Hello:shutdown() 
  jump() print ("\t\t\tHELLO COMPONENT VERSION 2 SHUTTING DOWN")
--  for k, v in pairs(self.context) do print(k,v) end
  if (oil.orb) then
    for k, v in pairs(self.context) do 
      if (type(k) == "string") and (k:sub(1,1) ~= "_") then
        print("Deactivating " .. tostring(k))
        oil.orb:deactivate(v)
      end
    end
  end
  jump() 
end

return { [HELLO_FACET_NAME] = Hello, shutdown = Hello.shutdown, startup = Hello.startup }

