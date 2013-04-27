local oo = require "loop.base"
local oil = require "oil"
--local suspender = require "suspension"

local orb = oil.init({host = "localhost", port = 1081, flavor = "cooperative;corba.intercepted"})
oil.orb = orb

local scs          = require "scs.core.base"
local scsAdaptive  = require "scs.core.adaptive"
--local scsComposite = require "scs.core.composite"

oil.verbose:level(0)


local IDL_BASE_DIR = os.getenv("IDL_PATH")

orb:loadidlfile(IDL_BASE_DIR .. "scs.idl")
orb:loadidlfile(IDL_BASE_DIR .. "hello.idl")
orb:loadidlfile(IDL_BASE_DIR .. "composite.idl")
orb:loadidlfile(IDL_BASE_DIR .. "lifecycle.idl")

 --------------------------
--- HELLO IMPLEMENTATION ---
 --------------------------
local HELLO_IDL_NAME = "IDL:scs/demos/helloworld/IHello:1.0"
local iHello = "IHello"
local Hello = oo.class{name = "Hello World"}
function Hello:sayHello(str) 
  print(str) 
  --error(orb:newexcept{ "::scs::core::lifecycle::HaltedComponent" , msg = "Component is halted and cannot process request" })
end

local facetDescs = {}
facetDescs.IHello = {
  name = iHello,
  interface_name = HELLO_IDL_NAME,
  class = Hello,
}
facetDescs.IComponent = {
  name           = "IComponent",
  interface_name = "IDL:scs/core/IComponent:1.0",
  class          = scs.Component,
-- hack to easy locate the proxy to this component later
  key            = "Hello" 
}

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if (ident and ident > 2) then return end
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => table\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        table_print (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end

--for k, _ in ipairs(helloIDL) do print(k) end
--table_print(helloIDL)

local receptDescs = {}

local cpId = {
  name = "Hello",
  major_version = 1,
  minor_version = 0,
  patch_version = 0,
  platform_spec = ""
}

oil.main(function ()

  oil.newthread(orb.run, orb)
  --orb:setserverinterceptor(Suspender)

  local hello, msg = scsAdaptive.newAdaptiveComponent(facetDescs, receptDescs, cpId, true)
  --local hello, msg = scsComposite.newCompositeComponent(facetDescs, receptDescs, cpId)
  --local hello, msg = scs.newComponent(facetDescs, receptDescs, cpId)

  if (hello) then
    oil.writeto("hello.ior",orb:tostring(hello.IComponent))
  else
    print(msg)
  end

end)
