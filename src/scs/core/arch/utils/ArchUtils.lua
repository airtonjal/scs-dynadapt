require "scs.core.arch.utils.ArchConfig"

--------------------------
-- SCS Version -----------
--------------------------

_scs_version       = "1.0"
_scs_core_package  = "scs/core/"
_arch_package      = _scs_core_package .. "arch/"
_lifecycle_package = _scs_core_package .. "lifecycle/"
_deployer_package  = _arch_package     .. "deploy/"

--------------------------
-- ENUMS -----------------
--------------------------
ONE_TO_MANY = "ONE_TO_MANY"
ONE_TO_ONE  = "ONE_TO_ONE"
MANY_TO_ONE = "MANY_TO_ONE"

RESUMED     = "RESUMED"
HALTED      = "HALTED"
SUSPENDED   = "SUSPENDED"

--------------------------
-- SCS -------------------
--------------------------
ICOMPONENT_NAME     = "IComponent"
IMETA_NAME          = "IMetaInterface"
IRECEP_NAME         = "IReceptacles"
ICOMPONENT_IDL_NAME = _scs_core_package .. ICOMPONENT_NAME .. ":" .. _scs_version
IMETA_IDL_NAME      = _scs_core_package .. IMETA_NAME .. ":" .. _scs_version
IRECEP_IDL_NAME     = _scs_core_package .. IRECEP_NAME .. ":" .. _scs_version
IDL_ICOMPONENT      = "IDL:" .. ICOMPONENT_IDL_NAME
IDL_IMETA           = "IDL:" .. IMETA_IDL_NAME
IDL_IRECEP          = "IDL:" .. IRECEP_IDL_NAME
ICOMPONENT_INT_NAME = "::"   .. ICOMPONENT_IDL_NAME:gsub("/","::")
IMETA_INT_NAME      = "::"   .. IMETA_IDL_NAME:gsub("/", "::")
IRECEP_INT_NAME     = "::"   .. IRECEP_IDL_NAME:gsub("/", "::")

--------------------------
-- LIFECYCLE -------------
--------------------------

LIFECYCLE_FACET_NAME = "LifeCycle"
ILIFECYCLE_NAME      = "I" .. LIFECYCLE_FACET_NAME
LIFECYCLE_IDL_NAME   = _lifecycle_package .. ILIFECYCLE_NAME .. ":" .. _scs_version
IDL_LIFECYCLE        = "IDL:" .. LIFECYCLE_IDL_NAME
LIFECYCLE_INT_NAME   = "::" .. LIFECYCLE_IDL_NAME:gsub("/","::")

--------------------------
-- ARCHITECTURE MANAGER --
--------------------------

ARCH_MANAGER_FACET_NAME = "ArchManager"
IARCH_MANAGER_NAME      = "I" .. ARCH_MANAGER_FACET_NAME
ARCH_MANAGER_IDL_NAME   = _arch_package .. IARCH_MANAGER_NAME .. ":" .. _scs_version
IDL_ARCH_MANAGER        = "IDL:" .. ARCH_MANAGER_IDL_NAME
ARCH_MANAGER_INT_NAME   = "::" .. ARCH_MANAGER_IDL_NAME:gsub("/","::")


--------------------------
-- DEPLOYER --------------
--------------------------

DEPLOYER_FACET_NAME = "Deployer"
IDEPLOYER_NAME      = "I" .. DEPLOYER_FACET_NAME
DEPLOYER_IDL_NAME   = _deployer_package .. IDEPLOYER_NAME .. ":" .. _scs_version
IDL_DEPLOYER        = "IDL:" .. DEPLOYER_IDL_NAME
DEPLOYER_INT_NAME   = "::" .. DEPLOYER_IDL_NAME:gsub("/","::")

--------------------------
-- EXCEPTIONS
--------------------------

_arch_package_ex          = "IDL:" .. _arch_package
INVALID_ADL_EX            = _arch_package_ex .. "InvalidADL"           .. ":" .. _scs_version
START_SYSTEM_FAILED_EX    = _arch_package_ex .. "StartSystemFailed"    .. ":" .. _scs_version
UNAVAILABLE_MACHINE_EX    = _arch_package_ex .. "UnavailableMachine"   .. ":" .. _scs_version
MACHINE_ALREADY_EXISTS_EX = _arch_package_ex .. "MachineAlreadyExists" .. ":" .. _scs_version
INVALID_MACHINE_EX        = _arch_package_ex .. "InvalidMachine"       .. ":" .. _scs_version
NOT_STARTED_EX            = _arch_package_ex .. "NotStarted"           .. ":" .. _scs_version
ALREADY_STARTED_EX        = _arch_package_ex .. "AlreadyStarted"       .. ":" .. _scs_version
NO_DEPLOYER_EX            = _arch_package_ex .. "NoDeployer"           .. ":" .. _scs_version
INSTALL_ERROR_EX          = _arch_package_ex .. "InstallError"         .. ":" .. _scs_version
RUN_ERROR_EX              = _arch_package_ex .. "RunError"             .. ":" .. _scs_version
SHUTDOWN_ERROR_EX         = _arch_package_ex .. "ShutdownError"        .. ":" .. _scs_version
NONEXISTENT_INSTANCE_EX   = _arch_package_ex .. "NonExistentInstance"  .. ":" .. _scs_version

_deployer_package_ex  = "IDL:" .. _deployer_package
ALREADY_REGISTERED_EX = _deployer_package_ex .. "AlreadyRegistered"    .. ":" .. _scs_version
NO_IMPLEMENTATION_EX  = _deployer_package_ex .. "NoImplementation"     .. ":" .. _scs_version
UNKNOWN_SERVICE_EX    = _deployer_package_ex .. "UnknownService"       .. ":" .. _scs_version
NOT_INSTALLED_EX      = _deployer_package_ex .. "NotInstalled"         .. ":" .. _scs_version

--------------------------
-- COMPONENTS ------------
--------------------------

--------------------------
-- ARCHITECTURE MANAGER --
--------------------------

ARCH_MANAGER_COMPONENT_NAME = ARCH_MANAGER_FACET_NAME
ARCH_MANAGER_ICOMPONENT_KEY = ARCH_MANAGER_COMPONENT_NAME .. ICOMPONENT_NAME
ARCH_MANAGER_KEY            = ARCH_MANAGER_FACET_NAME

--------------------------
-- DEPLOYER --------------
--------------------------

DEPLOYER_COMPONENT_NAME = DEPLOYER_FACET_NAME
DEPLOYER_ICOMPONENT_KEY = DEPLOYER_COMPONENT_NAME .. ICOMPONENT_NAME
DEPLOYER_KEY            = DEPLOYER_FACET_NAME

function toStringIDL()
--  print("\n------- PACKAGES -------\n")
  print("\n______________________________________________________________________________")
  print("-    -    -    -    -    -    -   PACKAGES   -    -    -    -    -    -    -")
  print("‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾")
  print("_scs_version\t\t\t->\t"     .. _scs_version)
  print("_scs_core_package\t\t->\t"  .. _scs_core_package)
  print("_arch_package\t\t\t->\t"    .. _arch_package)
  print("_lifecycle_package\t\t->\t" .. _lifecycle_package)

  print("\n\n______________________________________________________________________________")
  print("-    -    -    -    -    -    -   INTERFACES   -    -    -    -    -    -    -")
  print("‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾")
  print("\n------- SCS ------------------------------------------------------------------\n")
  print("ICOMPONENT_NAME\t\t\t->\t"       .. ICOMPONENT_NAME)
  print("ICOMPONENT_IDL_NAME\t\t->\t"     .. ICOMPONENT_IDL_NAME)
  print("IDL_ICOMPONENT\t\t\t->\t"        .. IDL_ICOMPONENT)
  print("ICOMPONENT_INT_NAME\t\t->\t"     .. ICOMPONENT_INT_NAME)
  print("\nIMETA_NAME\t\t\t->\t"          .. IMETA_NAME)
  print("IMETA_IDL_NAME\t\t\t->\t"        .. IMETA_IDL_NAME)
  print("IDL_IMETA\t\t\t->\t"             .. IDL_IMETA)
  print("IMETA_INT_NAME\t\t\t->\t"        .. IMETA_INT_NAME)
  print("\nIRECEP_NAME\t\t\t->\t"         .. IRECEP_NAME)
  print("IRECEP_IDL_NAME\t\t\t->\t"       .. IRECEP_IDL_NAME)
  print("IDL_IRECEP\t\t\t->\t"            .. IDL_IRECEP)
  print("IRECEP_INT_NAME\t\t\t->\t"       .. IRECEP_INT_NAME)
  print("\n------- LIFECYCLE ------------------------------------------------------------\n")
  print("ILIFECYCLE_NAME\t\t\t->\t"       .. ILIFECYCLE_NAME)
  print("LIFECYCLE_IDL_NAME\t\t->\t"      .. LIFECYCLE_IDL_NAME)
  print("IDL_LIFECYCLE\t\t\t->\t"         .. IDL_LIFECYCLE)
  print("LIFECYCLE_INT_NAME\t\t->\t"      .. LIFECYCLE_INT_NAME)
  print("\n------- ARCHITECTURE MANAGER -------------------------------------------------\n")
  print("ARCH_MANAGER_FACET_NAME\t\t->\t" .. ARCH_MANAGER_FACET_NAME)
  print("IARCH_MANAGER_NAME\t\t->\t"      .. IARCH_MANAGER_NAME)
  print("ARCH_MANAGER_IDL_NAME\t\t->\t"   .. ARCH_MANAGER_IDL_NAME)
  print("IDL_ARCH_MANAGER\t\t->\t"        .. IDL_ARCH_MANAGER)
  print("ARCH_MANAGER_INT_NAME\t\t->\t"   .. ARCH_MANAGER_INT_NAME)
  print("\n------- DEPLOYER -------------------------------------------------------------\n")
  print("DEPLOYER_FACET_NAME\t\t->\t"     .. DEPLOYER_FACET_NAME)
  print("IDEPLOYER_NAME\t\t\t->\t"        .. IDEPLOYER_NAME)
  print("DEPLOYER_IDL_NAME\t\t->\t"       .. DEPLOYER_IDL_NAME)
  print("IDL_DEPLOYER\t\t\t->\t"          .. IDL_DEPLOYER)
  print("DEPLOYER_INT_NAME\t\t->\t"       .. DEPLOYER_INT_NAME)
  
  print("\n\n______________________________________________________________________________")
  print("-    -    -    -    -    -    -   COMPONENTS   -    -    -    -    -    -    -")
  print("‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾")
  print("\n------- ARCHITECTURE MANAGER -------------------------------------------------\n")
  print("ARCH_MANAGER_COMPONENT_NAME\t->\t" .. ARCH_MANAGER_COMPONENT_NAME)
  print("ARCH_MANAGER_ICOMPONENT_KEY\t->\t" .. ARCH_MANAGER_ICOMPONENT_KEY)
  print("ARCH_MANAGER_KEY\t\t->\t"          .. ARCH_MANAGER_KEY)
  print("\n------- DEPLOYER -------------------------------------------------------------\n")
  print("DEPLOYER_COMPONENT_NAME\t\t->\t"   .. DEPLOYER_COMPONENT_NAME)
  print("DEPLOYER_ICOMPONENT_KEY\t\t->\t"   .. DEPLOYER_ICOMPONENT_KEY)
  print("DEPLOYER_KEY\t\t\t->\t"            .. DEPLOYER_KEY)
  
  print("\n\n______________________________________________________________________________")
  print("-    -    -    -    -    -    -   EXCEPTIONS   -    -    -    -    -    -    -")
  print("‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾")
  print("\n------- ARCHITECTURE MANAGER -------------------------------------------------\n")
  print("INVALID_ADL_EX\t\t\t->\t"        .. INVALID_ADL_EX)
  print("START_SYSTEM_FAILED_EX\t\t->\t"  .. START_SYSTEM_FAILED_EX)
  print("UNAVAILABLE_MACHINE_EX\t\t->\t"  .. UNAVAILABLE_MACHINE_EX)
  print("MACHINE_ALREADY_EXISTS_EX\t->\t" .. MACHINE_ALREADY_EXISTS_EX)
  print("INVALID_MACHINE_EX\t\t->\t"      .. INVALID_MACHINE_EX)
  print("NOT_STARTED_EX\t\t\t->\t"        .. NOT_STARTED_EX)
  print("ALREADY_STARTED_EX\t\t->\t"      .. ALREADY_STARTED_EX)
  print("NO_DEPLOYER_EX\t\t\t->\t"        .. NO_DEPLOYER_EX)
  print("INSTALL_ERROR_EX\t\t->\t"        .. INSTALL_ERROR_EX)
  print("RUN_ERROR_EX\t\t\t->\t"          .. RUN_ERROR_EX)
  print("SHUTDOWN_ERROR_EX\t\t->\t"       .. SHUTDOWN_ERROR_EX)
  print("NONEXISTENT_INSTANCE_EX\t\t->\t" .. NONEXISTENT_INSTANCE_EX)
  print("\n------- DEPLOYER -------------------------------------------------------------\n")
  print("ALREADY_REGISTERED_EX\t\t->\t"   .. ALREADY_REGISTERED_EX)
  print("NO_IMPLEMENTATION_EX\t\t->\t"    .. NO_IMPLEMENTATION_EX)
  print("UNKNOWN_SERVICE_EX\t\t->\t"      .. UNKNOWN_SERVICE_EX)
  print("NOT_INSTALLED_EX\t\t->\t"        .. NOT_INSTALLED_EX)
  
  print()
end

if (arg and arg[1] and arg[1] == "a") then toStringIDL() end

function toStringArch(tt, indent, done)
  done = done or {}
  indent = indent or 0
  ret = ""
  if (ident and ident > 2) then return end
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      ret = ret .. string.rep (" ", indent) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        if (type(key) == "string") and (key == "impl") then
          ret = ret .. string.format("[%s] => [ ::: LUA CODE ::: ]" .. "\n", tostring (key))
        else
          ret = ret .. string.format("[%s] => " .. tostring(value) .. "\n", tostring (key))
        end
        ret = ret .. string.rep (" ", indent + 4) -- indent it
        ret = ret .. "(\n";
        ret = ret .. toStringArch (value, indent + 7, done)
        ret = ret .. string.rep (" ", indent + 4) -- indent it
        ret = ret .. ")\n";
      else
        if (type(key) == "string") and (key == "impl") then
          ret = ret .. string.format("[%s] => [ ::: LUA CODE ::: ]" .. "\n", tostring (key))
        else
          ret = ret .. string.format("[%s] => %s\n", tostring (key), tostring(value))
        end
      end
    end
  else
    ret = ret .. tt .. "\n"
  end
  return ret
end

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if (ident and ident > 2) then return end
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => " .. tostring(value) .. "\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        table_print (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n", tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end

function table_size(tab)
  if (not tab or not type(tab) == "table") then return nil end
  local size = 0
  for k, v in pairs(tab) do size = size + 1 end
  return size
end

--
-- Description: Gets the current machine ip address on the specified network interface. If no interface is provided, eth0 is used
-- Return: A string containing the ip address
--
function getIP(iface)
  --local ret = os.execute("ifconfig eth0")
  iface = iface or "eth0"
  local handle, err = io.popen("ifconfig " .. iface)
  if (handle) then
    local cmdOutput = handle:read('*a')
    local _, start = string.find(cmdOutput, "inet addr:" )
    start = start + 1
    local _, endstr = string.find(cmdOutput, " ", start)
    endstr = endstr - 1
    local ip = string.sub(cmdOutput, start, endstr)
    return ip
  else
    error(err)
  end
end

function getHostName()
  local handle, err = io.popen("uname -n")
  if (handle) then
    local cmdOutput = handle:read('*a')
    return cmdOutput:sub(1, #cmdOutput - 1)
  end
end

function booleanString(boolean)
  if (boolean) then return "true" else return "false" end
end

function corbaloc(ip, port, key)
  local ret = "corbaloc:iiop:" .. ip .. ":" .. port .. "/" .. key 
  return ret
end

-- FROM AMADEU's CODE :)
function isProxyNonExistent(prx)
  -- FIXME: oil-0.4beta tem um bug que a chamada do _non_existent pode retornar exceção, no oil-0.5 foi corrigido
  if not prx then return true end
  local ok, result = oil.pcall(prx._non_existent, prx)
  if (result == true) or (not ok and result[1]=="IDL:omg.org/CORBA/COMM_FAILURE:1.0") then
    return true
  else
    if (result and result[1]) then output("Exception ocurred while asking _non_existent: " .. result[1]) end
    return false
  end
end

function is(prx, idl)
  if not prx then return false end
  local ok, result = oil.pcall(prx._is_a, prx, idl)
  if (not ok) then
    print("is_a call did not went ok") return false
  elseif (result == true) then return true
  else return false
  end
end

--
-- Description: Converts a table with an alphanumeric indice to an array.
-- Parameter message: Table to be converted.
-- Return Value: The array.
--
function deepConvertToArray(inputTable, done)
  done = done or {}
  local outputArray = {}
  local i = 1
  for index, item in pairs(inputTable) do
    --table.insert(outputArray, item)
    if index ~= "n" then
      outputArray[i] = item
      i = i + 1
    end
  end
  done [inputTable] = true
  for i=1,#outputArray do
    local item = outputArray[i]
    if (type(item) == "table") and not done[item] then
      outputArray[i] = deepConvertToArray(item, done)
    end
    done[item] = true
  end
  return outputArray
end

local function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  for filename in popen('ls -a "'..directory..'"'):lines() do
    i = i + 1
    t[i] = filename
  end
  return t
end

--
-- Description: Loads all idl files from the specified directory
-- Parameter directory: Directory path
-- Parameter orb: The OiL orb
--
function loadIDL(directory, orb)
  local files = scandir(directory)

  for _, filename in ipairs(files) do
    local length = #filename
    if (length >= 4) then
      local sub = filename:sub ( length - 2 )
      if ( sub == "idl" ) then
    --    print("Loading " .. directory .. filename)
        orb:loadidlfile(directory .. filename)
--      else
      --  print("\"" .. filename .. "\" is not a idl file\tignoring...")
      end
  --  else
    --  print("\"" .. filename .. "\" is not a idl file\tignoring...")
    end
  end

end

--[[function deepcopy(t, done)
  done = done or {}
  if type(t) ~= 'table' then return t end
  local res = {}
  for k, v in pairs(t) do
    if type(v) == 'table' and not done[v] then
      done[v] = true
      v = deepcopy(v, done)
    else
      res[k] = v
    end
    res[k] = v
  end
  return res
end]]--

function deepcopy(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  return _copy(object)
end


function getORB(oil)
  if (not oil) then return nil end
  --if (oil.orb) then return orb end

  if (not oil.orb) then
    local caller = debug.getinfo(2).source
    local ip = getIP()
  
    print("Starting orb on " .. caller .. "\tIP: " .. ip .. "\tPort: " .. DEFAULT_ORB_PORT)
    oil.orb = oil.init({host = ip, port = DEFAULT_ORB_PORT, flavor = "cooperative;corba.intercepted"})
    --for k, v in pairs(orb.ValueEncoder.factories) do print(k, v) return nil end
  end

  -- Disables collocations, always goes through proxies
  oil.orb.ProxyManager.servants = nil
  --disableCollocation(oil.orb)
  return oil.orb
end

--
-- Description: converts a array into a map.
-- Param table: The array/table to be converted
-- Param key: The name of the attribute inside the table to convert to
-- Return: A map
--
function toMap(table, key)
  if (not table) then print("nil, returning") return nil end
  local newMap = {}
  if (key) then
    for _, v in ipairs(table) do
      if (type(v) == "table") and (v[key]) then
        newMap[v[key]] = v
      end
    end
  end
  for k, v in pairs(table) do
    if (type(k) ~= "number" and k ~= "n") then 
      newMap[k] = v
    end
  end
  return newMap
end



















