--[[
     _    ____   ____ _   _ ___ _____ _____ ____ _____ _   _ ____  _____      __  __    _    _   _    _    ____ _____ ____  
    / \  |  _ \ / ___| | | |_ _|_   _| ____/ ___|_   _| | | |  _ \| ____|    |  \/  |  / \  | \ | |  / \  / ___| ____|  _ \ 
   / _ \ | |_) | |   | |_| || |  | | |  _|| |     | | | | | | |_) |  _|      | |\/| | / _ \ |  \| | / _ \| |  _|  _| | |_) |
  / ___ \|  _ <| |___|  _  || |  | | | |__| |___  | | | |_| |  _ <| |___     | |  | |/ ___ \| |\  |/ ___ | |_| | |___|  _ < 
 /_/   \_|_| \_\\____|_| |_|___| |_| |_____\____| |_|  \___/|_| \_|_____|    |_|  |_/_/   \_|_| \_/_/   \_\____|_____|_| \_\
                                                                                                                            
--]]

local scs        = require "scs.core.base"
local scsAdaptive   = require "scs.core.adaptive"
local composite  = require "scs.core.composite"
local oo         = require "loop.base"
local oil        = require "oil"
local Deployer   = require "scs.core.arch.Deployer"
local Machine    = require "scs.core.arch.Machine"
local utils      = require "scs.core.utils"
utils = utils.Utils()

require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"

local toMap         = toMap
local toStringArch  = toStringArch
local corbaloc      = corbaloc
local booleanString = booleanString
local table_print   = table_print
local table_size    = table_size
local table_contents = table_contents
local getIP         = getIP
local isProxyNonExistent = isProxyNonExistent
local is            = is
local error         = error
local module        = module
local require       = require
local assert        = assert
local print         = print
local pairs         = pairs
local table         = table
local setmetatable  = setmetatable
local ipairs        = ipairs
local os            = os
local tostring      = tostring
local type          = type
local string        = string
local table         = table
local io            = io

-- Importing IDLs and exceptions
local ARCH_MANAGER_FACET_NAME = ARCH_MANAGER_FACET_NAME
local IDL_ARCH_MANAGER        = IDL_ARCH_MANAGER
local ARCH_MANAGER_INT_NAME   = ARCH_MANAGER_INT_NAME

local IDL_DEPLOYER = IDL_DEPLOYER

local ICOMPONENT_NAME = ICOMPONENT_NAME
local IDL_ICOMPONENT  = IDL_ICOMPONENT
local IMETA_NAME      = IMETA_NAME
local IDL_IMETA       = IDL_IMETA
local IRECEP_NAME     = IRECEP_NAME
local IDL_IRECEP      = IDL_IRECEP
local ILIFECYCLE_NAME = ILIFECYCLE_NAME
local IDL_LIFECYCLE   = IDL_LIFECYCLE

local ONE_TO_MANY = ONE_TO_MANY
local MANY_TO_ONE = MANY_TO_ONE
local ONE_TO_ONE  = ONE_TO_ONE

local RESUMED   = RESUMED
local HALTED    = HALTED
local SUSPENDED = SUSPENDED

-- EXCEPTIONS
local INVALID_ADL_EX            = INVALID_ADL_EX
local START_SYSTEM_FAILED_EX    = START_SYSTEM_FAILED_EX
local UNAVAILABLE_MACHINE_EX    = UNAVAILABLE_MACHINE_EX
local MACHINE_ALREADY_EXISTS_EX = MACHINE_ALREADY_EXISTS_EX
local INVALID_MACHINE_EX        = INVALID_MACHINE_EX
local NOT_STARTED_EX            = NOT_STARTED_EX
local ALREADY_STARTED_EX        = ALREADY_STARTED_EX
local NO_DEPLOYER_EX            = NO_DEPLOYER_EX
local INSTALL_ERROR_EX          = INSTALL_ERROR_EX
local RUN_ERROR_EX              = RUN_ERROR_EX
local NONEXISTENT_INSTANCE_EX   = NONEXISTENT_INSTANCE_EX

local UNKNOWN_SERVICE_EX        = UNKNOWN_SERVICE_EX
local ALREADY_REGISTERED_EX     = ALREADY_REGISTERED_EX
local NOT_INSTALLED_EX          = NOT_INSTALLED_EX
local NO_IMPLEMENTATION_EX      = NO_IMPLEMENTATION_EX

-- Component and interfaces naming
local ARCH_MANAGER_COMPONENT_NAME = ARCH_MANAGER_COMPONENT_NAME --"ArchManager"
local ARCH_MANAGER_ICOMPONENT_KEY = ARCH_MANAGER_ICOMPONENT_KEY -- "ArchManagerIComponent"
local ARCH_MANAGER_KEY = ARCH_MANAGER_KEY -- "IArchManager"

local DEPLOYER_FACET_NAME = DEPLOYER_FACET_NAME
local IDL_DEPLOYER = IDL_DEPLOYER
local DEPLOYER_KEY = DEPLOYER_KEY
local DEPLOYER_ICOMPONENT_KEY = DEPLOYER_ICOMPONENT_KEY


local MODULE = "scs.core.arch.ArchManager"

local DEBUG = VERBOSE.DEBUG 
local WARN  = VERBOSE.WARN 
local INFO  = VERBOSE.INFO
local DEBUG_PREFIX = "[" .. MODULE .. "] "

local _debug = debug
local getName = function() return debug.getinfo(2).name end
local debug = function(str) if (DEBUG) then print("[ DEBUG ] " .. DEBUG_PREFIX .. str) end end
--[[local debug = function(str)
  if (DEBUG) then
    local caller = _debug.getinfo(2).name
    caller = caller or ""
    caller = caller .. " " 
--    table_print(_debug.getinfo(2))
    print("[ DEBUG ] " .. DEBUG_PREFIX .. caller .. str)
  end
end]]--
local warn  = function(str) if (DEBUG) then print("[ WARN  ] " .. DEBUG_PREFIX .. str) end end
local info  = function(str) if (DEBUG) then print("[ INFO  ] " .. DEBUG_PREFIX .. str) end end

local DEFAULT_ORB_PORT = DEFAULT_ORB_PORT
-- If we stored a broker instance previously, use it. If not, use the default broker
local oil = oil
if (not oil.orb) then 
  debug("Starting orb on ArchManager.lua")
  oil.orb = oil.init{host = getIP(), port = DEFAULT_ORB_PORT, flavor = "cooperative;corba.intercepted"}
end
local _orb = oil.orb


--------------------------------------------------------------

module (MODULE)

--------------------------------------------------------------

local ArchManager = oo.class {
}

function ArchManager:__init()
--  debug("ArchManager() invoked")
  local self = oo.rawnew(self, {})

  -- Set of physical machines, indexed by the ips
  self.machines = {}
  
  -- Set of physical machines, indexed by their unique names
  self.machines_names = {}

  -- Set of Deployers IComponents
  self.deployersIComps = {}
  
  -- Set of Deployers facets
  self.deployersFacets = {}

  -- IComponent interface of each component of the system. The unique_name is the key
  self.icomponents = {}

  -- Each component role
  self.roles = {}

  -- The system defined in the ADL. This is variable is modified to only hold key-value pairs
  self.system = {}

  -- Started status
  self.started = false
  
  -- Acquire orb
  return self
end

function ArchManager:isStarted() 
  debug("ArchManager:isStarted() |--------------------------------------------- INVOKED   --------------------------------------------|")
  debug("ArchManager:isStarted()   Started: " .. booleanString(self.started) )
  debug("ArchManager:isStarted() |--------------------------------------------- RETURNING --------------------------------------------|\n")
  return self.started
end

function ArchManager:stopSystem()
  debug("ArchManager:stopSystem() |-------------------------------------------- INVOKED   --------------------------------------------|")
  -- TODO: Call IComponent:shutdown for every component on the composition, not the deployers
  debug("ArchManager:stopSystem() |-------------------------------------------- RETURNING --------------------------------------------|\n")
  return true
end

function ArchManager:getMachines()
  debug("ArchManager:getMachines() |------------------------------------------- INVOKED   --------------------------------------------|")
  local i = 0
  for k, v in pairs(self.machines) do i = i + 1 end
  debug("ArchManager:getMachines()   Machine set is of size " .. i)
  debug("ArchManager:getMachines() |------------------------------------------- RETURNING --------------------------------------------|\n")
  return utils:convertToArray(self.machines)
end

--
-- Description: Starts up a distributed system
-- Parameter: adl The Architectural Description Language. The table members are defined on the arch.idl file
--
function ArchManager:startSystem(adl)
  debug("ArchManager:startSystem(adl) |---------------------------------------- INVOKED ----------------------------------------------|")
  if (not self.started) then
    if (adl) then
      local system_name  = adl.system_name
      local architecture = adl.architecture
      local system       = adl.system
      local instances    = system.components
      local connections  = system.connections
 
      info("ArchManager:startSystem(adl)   Booting up system " .. system_name)
      if (table_size(self.machines) == 0) then
        warn("ArchManager:startSystem(adl)   No machine registered. Throwing: " .. NO_DEPLOYER_EX)
        error( _orb:newexcept{ NO_DEPLOYER_EX } )
      elseif (table_size(architecture) == 0) then 
        info("ArchManager:startSystem(adl)   No architecture description for system " .. system_name .. "\tNo constraints are gonna be imposed")
      end

      local key = "unique_name"

      -- TODO: Check if architecture description matches instances
      self:checkConsistency(architecture, system)
      --table_print(instances)

      self:checkAndAddMachines(instances)

      self:installSystem(instances)
      local icomponents = self:runSystem(instances)
      connections = toMap(connections, key)
      for connectionName, connection in pairs(connections) do
        connection.clients = toMap(connection.clients, key)
        connection.servers = toMap(connection.servers, key)
      end
      self:connectInstances(icomponents, connections)
      --print(toStringArch(connections))
      
      debug("ArchManager:startSystem(adl)   Starting up components with IComponent:startup")
      self:startupComponents(icomponents)

      debug("ArchManager:startSystem(adl)   Everything went ok. Assigning ArchManager variables")
      self.system_name  = system_name
      self.architecture = architecture
      self.system       = system
      self.instances    = instances
      self.icomponents  = icomponents
      self.connections  = connections
      self.started      = true
    end
  else
    debug("ArchManager:startSystem(adl)   System was previously started already. Throwing " .. ALREADY_STARTED_EX)
    error( _orb:newexcept{ ALREADY_STARTED_EX } )
  end
  debug("ArchManager:startSystem(adl) |---------------------------------------- RETURNING --------------------------------------------|\n")
  return true
end

function ArchManager:checkConsistency(architecture, system)
  debug("ArchManager:checkConsistency(architecture, system) INVOKED")
 
  local key = "unique_name"
  -- Converts to map to access more easily
  architecture.relationships = toMap(architecture.relationships, key)
  architecture.components    = toMap(architecture.components, key)

  --system.connection = 
  system.components          = toMap(system.components, key)
  --system.connections         = toMap(system.connections, key)
  
  --error( _orb:newexcept{ INVALID_ADL_EX, msg = "" } )
  debug("ArchManager:checkConsistency(architecture, system) RETURNING") 
end

function ArchManager:toStringArch()
  debug("ArchManager:toStringArch() |------------------------------------------ STARTING  --------------------------------------------|")
  local ret = ""
  if (self.instances) then
    ret = "COMPONENTS: [[\n" .. toStringArch(toMap(self.instances, "unique_name"), 2) .. "]]"
    if (self.connections) then
      ret = ret .. "\n\nCONNECTIONS: [[\n" .. toStringArch(toMap(self.connections, "unique_name" ), 2) .. "]]"
    end
  else 
    debug("ArchManager:toStringArch()   No component set found, returning empty string") 
  end
  local machs = ""

  for name, deployer in pairs(self.deployersIComps) do
    local status, id = oil.pcall(deployer.getComponentId, deployer)
    if (status) then
      machs = machs .. toStringArch(toMap(id), 2)
      machs = machs .. toStringArch(self.machines[name], 2)
    else 
      warn(id[1])
    end
  end
  if (machs ~= "") then ret = ret .. "\n\nMACHINES: [[\n" .. machs .. "]]"  end
  debug("ArchManager:toStringArch() |------------------------------------------ RETURNING --------------------------------------------|\n")
  return ret
end

function ArchManager:adapt( adaptation )
  debug("ArchManager:adapt(adaptation) |--------------------------------------- INVOKED   --------------------------------------------|")
  self:toAdaptedTable(adaptation)
  --TODO: Do something like checking the added roles, if removed relationships previously existed
  self:changeArchitecture(adaptation.architectureChange)
  self:addNewComponents(adaptation.systemChange.newComponents)
  
  self:suspendAndDisconnect(adaptation.systemChange.removed)
  --self:addConnections(adaptation.systemChange.added)
  self:connectInstances(self.icomponents, adaptation.systemChange.added)
  --self;resume()
  
  print(toStringArch(self.connections))
  --print(toStringArch(self.architecture))
  debug("ArchManager:adapt(adaptation) |--------------------------------------- RETURNING --------------------------------------------|\n")
end

function ArchManager:addConnections(added)
  debug("ArchManager:addConnections(added) Adding new connections")
  
  for connectionName, connection in pairs(added) do
    
  end
  debug("ArchManager:addConnections(added) Finished")
end

function ArchManager:suspendAndDisconnect(removed)
  debug("ArchManager:suspendAndDisconnect(removed) Removing old connections")
  local changed = {}
  for connectionName, connection in pairs(removed) do
    debug("ArchManager:suspendAndDisconnect(removed) Suspending components from connection " .. connectionName)
    for clientName, client in pairs(connection.clients) do
      if (not changed[client.unique_name]) then
        self:suspend(client)
        changed[client.unique_name] = client
      end
    end
    for serverName, server in pairs(connection.servers) do
      if (not changed[server.unique_name]) then
        self:suspend(server)
        changed[server.unique_name] = server
      end
    end
    
    debug("ArchManager:suspendAndDisconnect(removed) Components suspended, removing connections")
    self:disconnect(connection)

  end
  debug("ArchManager:suspendAndDisconnect(removed) Finished")
end

function ArchManager:disconnect(connection)
  debug("ArchManager:disconnect(connection) Disconnecting " .. connection.unique_name)
  for clientName, client in pairs(connection.clients) do
    for serverName, server in pairs(connection.servers) do
      local connectionId = self.connections[connection.unique_name][clientName][serverName]
      debug("ArchManager:disconnect(connection) Undoing connection between client " .. clientName .. " and server " .. serverName .. "\tConnection id: " .. connectionId )
      local clientIComponent = self.icomponents[clientName]
      local clientReceptacles = self:getNarrowedFacet(clientIComponent, IRECEP_NAME, IDL_IRECEP)
      local status, ret = oil.pcall(clientReceptacles.disconnect, clientReceptacles, connectionId)
      if (not status) then
        local msg = ret[1]
        warn("ArchManager:disconnect(connection) Could not disconnect components " .. msg)
      else
        self.connections[connection.unique_name] = nil
        info("ArchManager:disconnect(connection) Components " .. clientName .. " and " .. serverName .. " are now disconnected")
      end
    end
  end
end

function ArchManager:suspend(instance)
  debug("ArchManager:suspend(instance) Suspending component " .. instance.unique_name)
  local icomponent = self.icomponents[instance.unique_name]
  local lifecycle = self:getNarrowedFacet(icomponent, ILIFECYCLE_NAME, IDL_LIFECYCLE)
  local status, res = oil.pcall(lifecycle.changeState, lifecycle, HALTED)
  if (not status) then
    error( _orb:newexcept{ SHUTDOWN_ERROR_EX, msg = res[1] } )
  else
    info("ArchManager:suspend(instance) Component " .. instance.unique_name .. " is now suspended")
  end
end

function ArchManager:addNewComponents(newComponents)
  debug("ArchManager:addNewComponents(newComponents) Installing new components")
  for name, instance in pairs(newComponents) do
    debug("ArchManager:addNewComponents(newComponents) Installing component: " .. name)
    self:installInstance(instance)
  end
  debug("ArchManager:addNewComponents(newComponents) Running new components")
  for name, instance in pairs(newComponents) do
    debug("ArchManager:addNewComponents(newComponents) Running component: " .. name)
    local icomponent = self:runInstance(instance)
    self.icomponents[name] = icomponent
  end
  
  debug("ArchManager:addNewComponents(newComponents) Finished")
end


function ArchManager:changeArchitecture(architectureChange)
  debug("ArchManager:changeArchitecture(architectureChange) INVOKED")

  debug("ArchManager:changeArchitecture(architectureChange) Adding new roles")
  for roleName, role in pairs(architectureChange.newRoles) do
    debug("ArchManager:changeArchitecture(architectureChange) Adding role " .. roleName)
    self.architecture.components[roleName] = role
  end

  debug("ArchManager:changeArchitecture(architectureChange) Removing relationships")
  for relationshipName, _ in pairs(architectureChange.removed) do
    debug("ArchManager:changeArchitecture(architectureChange) Removing relationship " .. relationshipName)
    self.architecture.relationships[relationshipName] = nil
  end
  
  debug("ArchManager:changeArchitecture(architectureChange) Adding relationships")
  for relationshipName, relationship in pairs(architectureChange.added) do
    debug("ArchManager:changeArchitecture(architectureChange) Adding relationship " .. relationshipName)
    self.architecture.relationships[relationshipName] = relationship
  end
end

function ArchManager:toAdaptedTable(adaptation)
  local key = "unique_name"
  adaptation.architectureChange.removed  = toMap(adaptation.architectureChange.removed,  key)
  adaptation.architectureChange.added    = toMap(adaptation.architectureChange.added,    key)
  adaptation.architectureChange.newRoles = toMap(adaptation.architectureChange.newRoles, key)

  adaptation.systemChange.newComponents  = toMap(adaptation.systemChange.newComponents,  key)
  adaptation.systemChange.removed        = toMap(adaptation.systemChange.removed,        key)
  adaptation.systemChange.added          = toMap(adaptation.systemChange.added,          key)

  for connectionName, connection in pairs(adaptation.systemChange.removed) do
    connection.clients = toMap(connection.clients, key)
    connection.servers = toMap(connection.servers,  key)
  end
  for connectionName, connection in pairs(adaptation.systemChange.added) do 
    connection.clients = toMap(connection.clients, key)
    connection.servers = toMap(connection.servers,  key)
  end
end

function ArchManager:connectInstances(icomponents, connections)
  debug("ArchManager:connectInstances(icomponents, connections) INVOKED")
  --print(toStringArch(connections))
  --table_print(icomponents)
  for connectionName, connection in pairs(connections) do
    if (connection.id) then 
      info("ArchManager:connectInstances(icomponents, connections) " .. connection.unique_name .. " connection already has id " .. connection.id .. " (...) Skipping")
    else
      local relationship   = connection.relationship
      local service        = relationship.service
      local clients        = connection.clients
      local servers        = connection.servers
      local arity          = service.arity
      local name           = service.name
      local interface_name = service.interface_name
      info("ArchManager:connectInstances(icomponents, connections) Arity: " .. arity .. "\tConnection name: " .. connectionName .. "\tService: " .. name )
      for clientName, client in pairs(clients) do
        local clientIComponent = icomponents[clientName]
        debug("ArchManager:connectInstances(icomponents, connections) Acquiring client " .. IRECEP_NAME .. " facet")
        local clientReceptacle = self:getNarrowedFacet(clientIComponent, IRECEP_NAME, IDL_IRECEP)
        if (not clientReceptacle) then  error( _orb:newexcept{ RUN_ERROR_EX, msg = "Cannot acquire " .. clientName .. " facet " .. IRECEP_NAME } ) end

        for serverName, server in pairs(servers) do
          local serverIComponent = icomponents[serverName]
          
          debug("ArchManager:connectInstances(icomponents, connections) Acquiring reference to server " .. serverName .. " facet " .. name)
          local serverFacet = serverIComponent:getFacetByName(name)
          if (not serverFacet) then  error( _orb:newexcept{ RUN_ERROR_EX, msg = "Cannot acquire " .. serverName .. " facet " .. name } ) end
          debug("ArchManager:connectInstances(icomponents, connections) Checking if server facet is of type: " .. interface_name .. "\tResult: " .. tostring(is(serverFacet, interface_name)))
      
          -- Connects and saves data structures
          self:addConnection(connection, clientName, serverName, name, clientReceptacle, serverFacet)
        end
      end
      --[[ if     (arity == ONE_TO_ONE)  then
        info("ArchManager:connectInstances(icomponents, connections) Connecting one client to one server with service")
        local client = clients[1]
        local server = servers[1]
        local clientName = client.unique_name
        local serverName = server.unique_name
        local clientIComponent = icomponents[clientName]
        local serverIComponent = icomponents[serverName]
        debug("ArchManager:connectInstances(icomponents, connections) Acquiring client " .. IRECEP_NAME .. " facet")
        local clientReceptacle = self:getNarrowedFacet(clientIComponent, IRECEP_NAME, IDL_IRECEP)
        if (not clientReceptacle) then  error( _orb:newexcept{ RUN_ERROR_EX, msg = "Cannot acquire " .. clientName .. " facet " .. IRECEP_NAME } ) end
        debug("ArchManager:connectInstances(icomponents, connections) Acquiring reference to server " .. serverName .. " facet " .. name)
        local serverFacet = serverIComponent:getFacetByName(name)
        if (not serverFacet) then  error( _orb:newexcept{ RUN_ERROR_EX, msg = "Cannot acquire " .. serverName .. " facet " .. name } ) end
        debug("ArchManager:connectInstances(icomponents, connections) Checking if server facet is of type: " .. interface_name .. "\tResult: " .. tostring(is(serverFacet, interface_name)))
      
        -- Connects and saves data structures
        self:addConnection(connection, clientName, serverName, name, clientReceptacle, serverFacet)
      elseif (arity == ONE_TO_MANY) then
        info("ArchManager:connectInstances(icomponents, connections) Connecting one client to many servers with service " .. interface_name)
        local client = clients[1]
        local clientName = client.unique_name
        local clientIComponent = icomponents[clientName]
        debug("ArchManager:connectInstances(icomponents, connections) Acquiring client " .. IRECEP_NAME .. " facet")
        local clientReceptacle = self:getNarrowedFacet(clientIComponent, IRECEP_NAME, IDL_IRECEP)
        if (not clientReceptacle) then  error( _orb:newexcept{ RUN_ERROR_EX, msg = "Cannot acquire " .. clientName .. " facet " .. IRECEP_NAME } ) end
        for _, server in ipairs(servers) do
          local serverName = server.unique_name
          local serverIComponent = icomponents[ serverName ]
          debug("ArchManager:connectInstances(icomponents, connections) Acquiring reference to server " .. serverName .. " facet " .. name)
          local serverFacet = serverIComponent:getFacetByName(name)
          if (not serverFacet) then  error( _orb:newexcept{ RUN_ERROR_EX, msg = "Cannot acquire " .. serverName .. " facet " .. name } ) end
          debug("ArchManager:connectInstances(icomponents, connections) Checking if server facet is of type: " .. interface_name .. "\tResult: " .. tostring(is(serverFacet, interface_name)))

          -- Connects and saves data structures
          self:addConnection(connection, clientName, serverName, name, clientReceptacle, serverFacet)
        end
      elseif (arity == MANY_TO_ONE) then
        info("ArchManager:connectInstances(icomponents, connections) Connecting many clients to one server with service " .. interface_name)
        local server = servers[1]
        local serverName = server.unique_name
        local serverIComponent = icomponents[serverName]
        debug("ArchManager:connectInstances(icomponents, connections) Acquiring reference to server " .. serverName .. " facet " .. name)
        local serverFacet = serverIComponent:getFacetByName(name)
        if (not serverFacet) then  error( _orb:newexcept{ RUN_ERROR_EX, msg = "Cannot acquire " .. serverName .. " facet " .. name } ) end
        debug("ArchManager:connectInstances(icomponents, connections) Checking if server facet is of type: " .. interface_name .. "\tResult: " .. tostring(is(serverFacet, interface_name) ))
        for _, client in ipairs(clients) do
          local clientName = client.unique_name
          local clientIComponent = icomponents[ client.unique_name ]
          debug("ArchManager:connectInstances(icomponents, connections) Acquiring client " .. IRECEP_NAME .. " facet")
          local clientReceptacle = self:getNarrowedFacet(clientIComponent, IRECEP_NAME, IDL_IRECEP)
          if (not clientReceptacle) then  error( _orb:newexcept{ RUN_ERROR_EX, msg = "Cannot acquire " .. clientName .. " facet " .. IRECEP_NAME } ) end

          -- Connects and saves data structures
          self:addConnection(connection, clientName, serverName, name, clientReceptacle, serverFacet)
        end
      end]]--
      --local receptacles = self:getNarrowedFacet(component, IRECEP_NAME, IDL_IRECEP)
    end
  end
  debug("ArchManager:connectInstances(icomponents, connections) RETURNING")
end

function ArchManager:addConnection( connection, clientName, serverName, name, clientReceptacle, serverFacet )
  debug("ArchManager:addConnection(c, c, s, n, c, s) Connecting client " .. clientName .. " to server " .. serverName)
  local status, res = oil.pcall(clientReceptacle.connect, clientReceptacle, name, serverFacet)
  if (not status) then
    local msg = "ArchManager:addConnection(c, c, s, n, c, s) Exception was caught when trying to connect client " .. clientName .. " to server " .. serverName .. "\tException: " .. res[1]
    warn(msg)
    error( _orb:newexcept{ RUN_ERROR_EX, msg = msg } )
  else
    --debug("ArchManager:addConnection(connections, clientName, serverName, clientReceptacle, serverFacet) conections." .. serverName .. "." .. clientName .. " will hold connection id " .. res)
    --connections[serverName][clientName] = res
    --debug("ArchManager:addConnection(connections, clientName, serverName, clientReceptacle, serverFacet) conections." .. clientName .. "." .. serverName .. " will hold connection id " .. res)
    --connections[clientName][serverName] = res
    debug("ArchManager:addConnection(c, c, s, n, c, s) Setting " .. connection.unique_name .. " connection with id " .. res)
    connection[clientName] = {}
    connection[serverName] = {}
    connection[clientName][serverName] = res
    connection[serverName][clientName] = res
  end

end

function ArchManager:replaceInstance(unique_name, newImpl)
  debug("ArchManager:replaceInstance(unique_name, newImpl) |------------------- INVOKED   --------------------------------------------|")
  local oldConnections = {}

  local oldIComp = self.icomponents[unique_name]
  local component = self.system.components[unique_name]
  if (not oldIComp) then  error( _orb:newexcept{ NONEXISTENT_INSTANCE_EX, msg = "ArchManager:replaceInstance(uniqueName, newImpl)   Could not find IComponent for component " .. tostring(unique_name) } ) end
  if (not component) then  error( _orb:newexcept{ NONEXISTENT_INSTANCE_EX, msg = "ArchManager:replaceInstance(uniqueName, newImpl)   Could not find component description of " .. tostring(unique_name) } ) end
  debug("ArchManager:replaceInstance(unique_name, newImpl)   Found IComponent interface and description for old instance of " .. unique_name)

  --TODO: Change the states of everyone connected to oldInst to suspended
  --TODO: Disconnect old Inst here
  --print(toStringArch(toMap(self.connections)))

  -- Halts the component to change its implementation
  local lifecycle = self:getNarrowedFacet(oldIComp, ILIFECYCLE_NAME, IDL_LIFECYCLE)
  local status, res = oil.pcall(lifecycle.changeState, lifecycle, SUSPENDED)
  if (not status) then
    error( _orb:newexcept{ RUN_ERROR_EX, msg = "ArchManager:replaceInstance(unique_name, newImpl)   Could not change " .. unique_name .. " state to " .. HALTED } )
  end

  local deployerFacet = self.deployersFacets[component.machine.host]
  if (not deployerFacet) then
    error ( _orb:newexcept{ NO_DEPLOYER_EX } )
  end
  debug("ArchManager:replaceInstance(unique_name, newImpl)   Trying to redeploy component with new implementation " .. unique_name)
  local status, ret = oil.pcall(deployerFacet.redeploy, deployerFacet, unique_name, newImpl)
  if (not status) then
    if ret[1] == RUN_ERROR_EX then
      warn(ret.msg)
      error( _orb:newexcept{ RUN_ERROR_EX, msg = ret.msg} )
    end
    error( _orb:newexcept{ RUN_ERROR_EX, msg = "ArchManager:replaceInstance(unique_name, newImpl)   Could not change implementation of " .. unique_name} )
  end 
  
  local status, res = oil.pcall(lifecycle.changeState, lifecycle, RESUMED)
  if (not status) then
    error( _orb:newexcept{ RUN_ERROR_EX, msg = "ArchManager:replaceInstance(unique_name, newImpl)   Could not change " .. unique_name .. " state to " .. RESUMED } )
  end

  
  -- Remove it from the map, to avoid trying to shut it down again
  --self.icomponents[unique_name] = nil
  
  --TODO: Connect new Inst here
  --TODO: Change the states of everyone connected to now to new Inst to resumed

  debug("ArchManager:replaceInstance(unique_name, newImpl) |------------------- RETURNING --------------------------------------------|\n")
  return true
end

function ArchManager:installSystem( instances )
  debug("ArchManager:installSystem(instances) INVOKED")

  info("ArchManager:installSystem(instances) Attempting to install system instances")
  for k, inst in ipairs(instances) do
    if (k ~= "n") then
      self:installInstance(inst)
    end
  end
  info("ArchManager:installSystem(instances) System instances were succesfully installed")

  debug("ArchManager:installSystem(instances) RETURNING")
end

function ArchManager:installInstance(inst)
  local deployer = self:getDeployerIComponent(inst.machine)
  --deployer = deployer:getFacetByName( DEPLOYER_FACET_NAME )
  --deployer = _orb:narrow( deployer, IDL_DEPLOYER )
  deployer = self:toDeployer(deployer, inst.machine.host)
  debug("ArchManager:installInstance(inst) Installing component " .. inst.unique_name .. " on machine " .. inst.machine.host)
  local status, res = oil.pcall(deployer.install, deployer, inst)
  if (not status) then
    if (res[1] == UNKNOWN_SERVICE_EX or res[1] == ALREADY_REGISTERED_EX) then
      local msg = "ArchManager:installInstance(inst) Exception was caught when trying to install instance " .. inst.unique_name .. " on deployer " .. inst.machine.host .. "\tException: " .. res[1]
      warn(msg)
      error( _orb:newexcept{ INSTALL_ERROR_EX, msg = msg } )
    else
      info("ArchManager:installInstance(inst) Component " .. inst.unique_name .. " instaled on machine " .. inst.machine.host)
    end
  end
end

function ArchManager:runSystem(instances)
  debug("ArchManager:runSystem(instances) INVOKED")
  info("ArchManager:runSystem(instances) Attempting to run system instances")
  local icomponents = {}
  
  for k, inst in ipairs(instances) do
    if (k ~= "n") then
      local icomponent = self:runInstance(inst, icomponents)
      icomponents[inst.unique_name] = icomponent
    end
  end
  info("ArchManager:runSystem(instances) System instances are running")
  debug("ArchManager:runSystem(instances) RETURNING")
  return icomponents
end

function ArchManager:runInstance( inst )
  local deployer = self:getDeployerIComponent(inst.machine)
  deployer = self:toDeployer(deployer, inst.machine.host)
  local status, icomponent = oil.pcall(deployer.run, deployer, inst.unique_name)
  if (not status) then
    if (icomponent[1] == NO_IMPLEMENTATION_EX or icomponent[1] == NOT_INSTALLED_EX) then
      local msg = "ArchManager:runInstance(inst) Exception was caught when trying to run instance " .. inst.unique_name .. " on deployer " .. inst.machine.host .. "\tException: " .. icomponent[1]
      warn(msg)
      error( _orb:newexcept{ RUN_ERROR_EX, msg = msg } )
    else
      error( _orb:newexcept{ RUN_ERROR_EX, msg = "ArchManager:runSystem(instances) An unkown error occurred on the deployer in " .. tostring(inst.machine.host) } )
    end
  else
    info("ArchManager:runInstance(inst) Instances of component " .. inst.unique_name .. " is now running on machine " .. inst.machine.host)
    return icomponent
  end
end

function ArchManager:startupComponents( icomponents )
  debug("ArchManager:startupComponents(icomponents) INVOKED")
  for name, component in pairs(icomponents) do
    debug("ArchManager:startupComponents(icomponents) Calling IComponent:startup() on component " .. name)
    local status, res = oil.pcall(component.startup, component)
    if (not status) then
      local msg = "ArchManager:startupComponents() Exception was caught when trying to startup component " .. name .. "\tException: " .. res[1]
      warn(msg)
      error( _orb:newexcept{ RUN_ERROR_EX, msg = msg } )
    end
  end
  debug("ArchManager:startupComponents(icomponents) RETURNING")
end

function ArchManager:shutdownSystem()
  debug("ArchManager:shutdownSystem() |---------------------------------------- INVOKED   --------------------------------------------|")
  for unique_name, icomponent in pairs(self.icomponents) do
    local lifecycle = self:getNarrowedFacet(icomponent, "ILifeCycle", IDL_LIFECYCLE)
    local status, res = oil.pcall(lifecycle.changeState, lifecycle, HALTED)
    if (not status) then
      error( _orb:newexcept{ SHUTDOWN_ERROR_EX, msg = res[1] } )
    else
      info("ArchManager:shutdownSystem()   Component " .. unique_name .. " is now halted")
    end
  end
  local err = ""
  for unique_name, icomponent in pairs(self.icomponents) do
    debug("ArchManager:shutdownSystem()   Invoking IComponent:shutdown() on " .. unique_name)
    local status, res = oil.pcall(icomponent.shutdown, icomponent)
    if (not status) then
      err = err .. res[1]
      warn("ArchManager:shutdownSystem()   Could not shutdown component " .. unique_name .. "\tException: " .. res[1])
    else
      info("ArchManager:shutdownSystem()   Component " .. unique_name .. " ran shutdown successfully")
    end
  end
  if (err ~= "") then error( _orb:newexcept{ SHUTDOWN_ERROR_EX, msg = err } ) end
  
  debug("ArchManager:shutdownSystem() |---------------------------------------- RETURNING --------------------------------------------|\n")
end

function ArchManager:getNarrowedFacet(icomponent, facetName, IDL)
  local facet = icomponent:getFacetByName( facetName )
  facet = _orb:narrow( facet, IDL )
  return facet
end

function ArchManager:checkAndAddMachines( instances )
  debug("ArchManager:checkAndAddMachines(instances) INVOKED")
  for k, inst in pairs(instances) do
    if (k ~= "n" and not self:exists(inst.machine)) then 
      info("ArchManager:checkAndAddMachines(instances) Machine with host " .. tostring(inst.machine.host) .. " was not previously added. Trying to start deployer component in it")
      self:addMachine(inst.machine)
    --elseif (k ~= "n") then
      --info("ArchManager:checkAndAddMachines(instances) Machine on host " .. tostring(inst.machine.host) .. " is ok")
    end
  end
  debug("ArchManager:checkAndAddMachines(instances) RETURNING")
end

function ArchManager:getSystemName()
  if (self.system_name) then return self.system_name else return "" end
end

function ArchManager:addMachines(machines)
  debug("ArchManager:addMachines(machines) INVOKED") --table_print(machines)
  -- TODO: Check if this works
  for _, v in pairs(machines) do self:addMachine(v) end
  return true;
end

function ArchManager:exists(machine)
  if (machine and machine.host and (self.machines[machine.host] and self.machines_names[machine.unique_name])) then
    return true
  else
    return false
  end
end

function ArchManager:addMachine(machine)
  debug("ArchManager:addMachine(machine) |------------------------------------- INVOKED ----------------------------------------------|")
  if (not machine or not machine.host or not machine.ssh_pass or not machine.ssh_user) then
    debug("ArchManager:addMachine(machine) \"machine\" parameter is not valid. Throwing " .. INVALID_MACHINE_EX)
    error ( _orb:newexcept{ INVALID_MACHINE_EX }) 
  elseif (self:exists(machine)) then
    debug("ArchManager:addMachine(machine) Machine with host " .. machine.host .. " is already registered. Throwing " .. MACHINE_ALREADY_EXISTS_EX)
    error ( _orb:newexcept{ MACHINE_ALREADY_EXISTS_EX })
  end
  -- TODO: Check if machines is accessible and if not thrown exception
  local mach = Machine( machine.unique_name, machine.host, machine.port, machine.ssh_user, machine.ssh_pass )
  --local status = mach:checkAvailability()
  debug("ArchManager:addMachine(machine) Starting deployer")
  local available, deployer = self:startDeployer(mach)
  if (not available) then
    error ( _orb:newexcept{ UNAVAILABLE_MACHINE_EX, msg = "Could not remotely start Deployer on machine " .. machine.unique_name}) 
  end
  debug("ArchManager:addMachine(machine) Adding machine " .. machine.host .. " to deployers set")
  self.machines[machine.host] = machine
  self.machines_names[machine.unique_name] = machine
  debug("ArchManager:addMachine(machine) |------------------------------------- RETURNING --------------------------------------------|")
  return true
end

--
-- Description: Troes to remotely start a Deployer component on the machine, if it is not started yet
-- Return: A boolean status indicating if the Deployer is available and the Deployer facet. If the Deployer cannot be started or is not found, false and an exception are returned
--
function ArchManager:startDeployer(machine)
  local deployer = self:getDeployerIComponent(machine)
  if (not deployer) then
    debug("ArchManager:startDeployer(machine) Host " .. machine.host .. " does not have a Deployer running. Starting it")
    machine:startDeployer()
    deployer = self:getDeployerIComponent(machine)
    if (deployer) then 
      debug("ArchManager:startDeployer(machine) Calling startup Deployer startup on host " .. machine.host)
      local status, res = oil.pcall(deployer.startup, deployer)
      if (not status) then 
        warn("ArchManager:startDeployer(machine) Something went wrong with the Deployer startup on host " .. machine.host .. "\tException: " .. res[1])
      else
        return status, deployer
      end
    end
  else
    info("ArchManager:startDeployer(machine) Host " .. machine.host .. " already has a Deployer running, no need to start it")
  end

  if (not deployer) then 
    return false, nil 
  else 
    --[[debug("ArchManager:startDeployer(machine) getting " .. DEPLOYER_FACET_NAME .. " facet")
    local deployer = deployer:getFacetByName( DEPLOYER_FACET_NAME )
    debug("ArchManager:startDeployer(machine) Narrowing " .. IDL_DEPLOYER .. " interface")

    deployer = _orb:narrow( deployer, IDL_DEPLOYER )
    
    debug("ArchManager:startDeployer(machine) Checking if deployer is available") 
    local status, res = oil.pcall(deployer.isAvailable, deployer)
    if (not status) then return false, res[1] end
    return res, deployer]]--
    deployer = self:toDeployer(deployer, machine.host)
    if (not deployer) then 
      debug("ArchManager:startDeployer(machine) Something weird happened while narrowing deployer facet") 
    else
      debug("ArchManager:startDeployer(machine) Found deployer facet, returning isAvailable() and deployer") 
      return deployer:isAvailable(), deployer
    end
  end 
end

--
-- Description: Tries to get the Deployer component running on the given machine
-- Return: The IComponent of the Deployer or nil if it's not running on the machine
--
function ArchManager:getDeployerIComponent(machine)
  --debug("ArchManager:getDeployerIComponent(machine) INVOKED")
  if (self.deployersIComps[machine.host]) then
    --debug("ArchManager:getDeployerIComponent(machine) Machine " .. machine.host .. " already exists on the set")
    --debug("ArchManager:getDeployerIComponent(machine) RETURNING")
    return self.deployersIComps[machine.host]
  else
    debug("ArchManager:getDeployerIComponent(machine) Acquiring Deployer IComponent on machine " .. machine.host)
  end

  local CORBALOC = corbaloc(machine.host, DEFAULT_ORB_PORT, DEPLOYER_ICOMPONENT_KEY)
  debug("ArchManager:getDeployerIComponent(machine) corbaloc: " .. CORBALOC)
  local deployerComponent = _orb:newproxy(CORBALOC, nil, IDL_ICOMPONENT)
  if ( isProxyNonExistent(deployerComponent) ) then 
    debug("ArchManager:getDeployerIComponent(machine) Could not find Deployer component on machine " .. machine.host)
    return nil
  elseif (not is(deployerComponent, IDL_ICOMPONENT)) then
    debug("Acquired proxy is not of type " .. IDL_ICOMPONENT)
    return nil
  end
  debug("ArchManager:getDeployerIComponent(machine) narrowing to idl: " .. IDL_ICOMPONENT)
  deployerComponent = _orb:narrow(deployerComponent, IDL_ICOMPONENT)
  if (not deployerComponent) then
    debug("ArchManager:getDeployerIComponent(machine) Could not narrow IComponent interface on host " .. machine.host)
    return nil
  end
  debug("ArchManager:getDeployerIComponent(machine) IComponent interface from Deployer was acquired from host " .. machine.host .. "\tAdding it to map")
  self.deployersIComps[machine.host] = deployerComponent
  --debug("ArchManager:getDeployerIComponent(machine) RETURNING")
  return deployerComponent
end

function ArchManager:toDeployer(deployer, host)
  --debug("ArchManager:toDeployer(deployer, host) INVOKED")
  if (self.deployersFacets[host]) then
    --debug("ArchManager:toDeployer(deployer, host) Deployer facet already exists on the set")
    --debug("ArchManager:toDeployer(deployer, host) RETURNING")
    return self.deployersFacets[host]
  end
  deployer = deployer:getFacetByName( DEPLOYER_FACET_NAME )
  if ( isProxyNonExistent(deployer)) then
    debug("PROXY IS NOT EXISTENT")
  elseif ( not is (deployer, IDL_DEPLOYER) ) then
    debug("IS NOT " .. IDL_DEPLOYER)
  else
    deployer = _orb:narrow(deployer, IDL_DEPLOYER)
    debug("ArchManager:toDeployer(deployer, host) Deployer facet acquired from host " .. host .. "\tAdding it to map")
    self.deployersFacets[host] = deployer
    debug("ArchManager:toDeployer(deployer, host) RETURNING new deployer")
    return deployer
  end
end

function ArchManager:shutdownDeployers()
  debug("ArchManager:shutdownDeployers() |------------------------------------- INVOKED   --------------------------------------------|")
  if (not self.started) then error ( _orb:newexcept{ NOT_STARTED_EX }) end
  for host, machine in pairs(self.machines) do
    local deployer = self:getDeployerIComponent(machine)
    local status, res = oil.pcall(deployer.shutdown, deployer)
    if (not status) then 
      error ( _orb:newexcept{ UNAVAILABLE_MACHINE_EX, msg = "Could invoke Deployer shutdown on host " .. machine.host .. "\t" .. res[1] })
    else
      debug("ArchManager:shutdownDeployers()   Deployer on machine " .. machine.host .. " was shutdown succesfully")
    end
  end
  debug("ArchManager:shutdownDeployers() |------------------------------------- RETURNING --------------------------------------------|\n")
  return true
end

--
-- Description: Adds a machine to the machines set
-- Parameter: force Set to true to force adding, even if it already exists or system is still not started
--
--function ArchManager:add(machine, force)
--  if (DEBUG) then debug("ArchManager:add invoked on arch.lua") table_print(machine) end
--end

scs.Component.startup = function ()
  debug("ArchManager:startup() |----------------------------------------------- INVOKED   --------------------------------------------|")
  debug("ArchManager:startup() |----------------------------------------------- RETURNING --------------------------------------------|\n")
end
scs.Component.shutdown = function ()
  debug("ArchManager:shutdown() |---------------------------------------------- INVOKED   --------------------------------------------|")
  debug("ArchManager:shutdown()   Deactivating ArchManager's servants")
  _orb:deactivate( ARCH_MANAGER_KEY )
  _orb:deactivate( ARCH_MANAGER_ICOMPONENT_KEY )
  debug("ArchManager:shutdown() |---------------------------------------------- RETURNING --------------------------------------------|\n")
end

local facetDescs = {}

facetDescs.IArchManager = {
  name           = ARCH_MANAGER_FACET_NAME,
  interface_name = IDL_ARCH_MANAGER,
  class          = ArchManager,
  key            = ARCH_MANAGER_KEY
}

facetDescs.IComponent = {
  name           = ICOMPONENT_NAME,
  interface_name = IDL_ICOMPONENT,
  class          = scs.Component,
-- hack to easy locate the proxy to this component later
  key            = ARCH_MANAGER_ICOMPONENT_KEY
}

local cpId = {
  name = ARCH_MANAGER_COMPONENT_NAME,
  major_version = 1,
  minor_version = 0,
  patch_version = 0,
  platform_spec = ""
}
local receptDescs = {}

--
-- Description: Starts the execution of the architect manager
-- Parameter config: Configurations to be passed to the orb
--
function startManager()
  debug("ArchManager:startManager starting")

  oil.main(function()
    oil.newthread(_orb.run, _orb)
    local archManager, msg = scsAdaptive.newAdaptiveComponent(facetDescs, receptDescs, cpId, true)
    --if (archManager) then
    --  oil.writeto("archmanager.ior", _orb:tostring(archManager.IComponent))
    --else
    if (not archManager) then
      error("Could not start ArchManager component. " .. msg)
    end
  end)
end

