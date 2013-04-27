--------------------------
-- HELLO -----------------
--------------------------
_hello_version = "1.0"
_hello_package  = "scs/demos/helloworld/"

HELLO_FACET_NAME = "IHello"
HELLO_IDL_NAME = _hello_package .. HELLO_FACET_NAME .. ":" .. _hello_version
IDL_IHELLO = "IDL:" .. HELLO_IDL_NAME
HELLO_INT_NAME = "::" .. HELLO_IDL_NAME:gsub("/","::")

function toStringIDL()
  print("\n------- PACKAGES -------\n")
  print("_hello_version\t\t->\t" .. _hello_version)
  print("_hello_package\t\t->\t" .. _hello_package)
  print("\n------- HELLO -------\n")
  print("HELLO_FACET_NAME\t\t->\t" .. HELLO_FACET_NAME)
  print("HELLO_IDL_NAME\t\t->\t" .. HELLO_IDL_NAME)
  print("IDL_IHELLO\t\t->\t" .. IDL_IHELLO)
  print("HELLO_INT_NAME\t\t->\t" .. HELLO_INT_NAME)
  print()
end

--if (arg[1] == "a") then toStringIDL() end

