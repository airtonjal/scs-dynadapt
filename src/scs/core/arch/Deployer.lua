--[[
  ____  _____ ____  _     _____   _______ ____  
 |  _ \| ____|  _ \| |   / _ \ \ / | ____|  _ \ 
 | | | |  _| | |_) | |  | | | \ V /|  _| | |_) |
 | |_| | |___|  __/| |__| |_| || | | |___|  _ < 
 |____/|_____|_|   |_____\___/ |_| |_____|_| \_\
                                                
--]]

local oo         = require "loop.base"
local oil        = require "oil"
local utils      = require "scs.core.utils"
local socket     = require "socket"
utils = utils.Utils()

require "scs.core.arch.utils.ArchUtils"
require "scs.core.arch.utils.ArchConfig"

local pcall         = pcall
local loadstring    = loadstring
local table_print   = table_print
local getIP         = getIP
local deepcopy      = deepcopy
local corbaloc      = corbaloc
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
local DEPLOYER_FACET_NAME     = DEPLOYER_FACET_NAME
local IDEPLOYER_NAME          = IDEPLOYER_NAME
local IDL_DEPLOYER            = IDL_DEPLOYER
local DEPLOYER_INT_NAME       = DEPLOYER_INT_NAME
local DEPLOYER_COMPONENT_NAME = DEPLOYER_COMPONENT_NAME
local DEPLOYER_ICOMPONENT_KEY = DEPLOYER_ICOMPONENT_KEY
local DEPLOYER_KEY            = DEPLOYER_KEY
local ALREADY_REGISTERED_EX   = ALREADY_REGISTERED_EX
local UNKNOWN_SERVICE_EX      = UNKNOWN_SERVICE_EX
local NOT_INSTALLED_EX        = NOT_INSTALLED_EX
local NO_IMPLEMENTATION_EX    = NO_IMPLEMENTATION_EX


local ICOMPONENT_NAME = ICOMPONENT_NAME
local IDL_ICOMPONENT = IDL_ICOMPONENT

local MODULE = "scs.core.arch.Deployer"

local DEBUG = VERBOSE.DEBUG
local WARN  = VERBOSE.WARN
local INFO  = VERBOSE.INFO
local DEBUG_PREFIX = "[" .. MODULE .. "] "
--oil.verbose:level(1)

--local _debug = debug
--local getName = function() return debug.getinfo(2).name end
local debug = function(str) if (DEBUG) then print("[ DEBUG ] " .. DEBUG_PREFIX .. str) end end
local warn  = function(str) if (WARN)  then print("[ WARN  ] " .. DEBUG_PREFIX .. str) end end
local info  = function(str) if (INFO)  then print("[ INFO  ] " .. DEBUG_PREFIX .. str) end end

local ip = getIP()
-- If we stored a broker instance previously, use it. If not, use the default broker
local oil = oil
local _orb = oil.orb
if (not _orb) then 
  debug("Starting orb on Deployer.lua\tIP: " .. ip .. "\tPort: " .. DEFAULT_ORB_PORT)
  _orb = oil.init({host = ip, port = DEFAULT_ORB_PORT, flavor = "cooperative;corba.intercepted"}) 
  oil.orb = _orb
end

-- Putting here avoid that oil is initialized with the default orb
local scs         = require "scs.core.base"
local scsAdaptive = require "scs.core.adaptive"
local composite   = require "scs.core.composite"

--------------------------------------------------------------

module (MODULE)

--------------------------------------------------------------

Deployer = oo.class {
  
}

function Deployer:__init()
  local self = oo.rawnew(self, {})

  self.running = {}

  self.installed  = {}

  return self
end

function Deployer:isAvailable()
  debug("Deployer:isAvailable() |---------------------------------------------- INVOKED   --------------------------------------------|")
  debug("Deployer:isAvailable() |---------------------------------------------- RETURNING --------------------------------------------|\n")
  return true
end

function Deployer:redeploy(unique_name, impl)
  debug("Deployer:redeploy(unique_name, impl) |------------------------------- INVOKED   --------------------------------------------|")
  local description = self.installed[unique_name]
  if (not description) then
    error( _orb:newexcept{ NOT_INSTALLED_EX, unique_name = unique_name } )
  end

  local loaded, err = loadstring(impl)
  if (not loaded) then
    error( _orb:newexcept{ RUN_ERROR_EX, msg = err } )
  end

  local status, ports = pcall(loaded)
  if (not status) then
    local msg
    if (type(ports) == "string") then msg = ports
    else msg = "Deployer:redeploy(unique_name, impl)   Could not load implementation of " .. unique_name
    end
    warn(msg)
    error( _orb:newexcept{ RUN_ERROR_EX, msg = msg } )
  else
    info("Deployer:redeploy(unique_name, impl)   New implementation of " .. unique_name .. " loaded successfully ") 
  end
  
  --info("SLEEPING FOR 10 SECONDS")
  --oil.sleep(10)

  local oldImpl = description.impl
  local runningComponent = self.running[unique_name]

  -- TODO: Solve how to replace startup and shutdown methods
  --for k,v in pairs(runningComponent._facetDescs.IComponent) do print(k,v) end
  local changeIComponent = false
  for name, newImpl in pairs(ports) do
    if (type(name) == "string") and (name == "startup" or name == "shutdown") then
      changeIComponent = true
    else
      local facet = runningComponent._facetDescs[name]
      debug("Deployer:redeploy(unique_name, impl)   Deactivating old servant of interface " .. facet.name) 
      local status, ret = oil.pcall(_orb.deactivate, _orb, facet.facet_ref)
      -- TODO: Rollback changes
      if (not status) then warn("Deployer:redeploy(unique_name, impl)   Could not deactivate facet " .. facet.name) end
      debug("Deployer:redeploy(unique_name, impl)   Recreating servant of interface " .. facet.name) 
      facet.facet_ref = _orb:newservant(newImpl, facet.key, facet.interface_name)
      runningComponent[name] = facet.facet_ref
    end
  end

  --for k, v in pairs(runningComponent._facetDescs) do print(k,v) end

  debug("Deployer:redeploy(unique_name, impl)   Replacing implementation of component " .. unique_name) 
  description.impl = impl

  debug("Deployer:redeploy(unique_name, impl) |------------------------------- RETURNING --------------------------------------------|\n")
end

function Deployer:install(component_instance)
  debug("Deployer:install(component_instance) |-------------------------------- INVOKED   --------------------------------------------|")

  local unique_name = component_instance.unique_name
  local role        = component_instance.role
  local impl        = component_instance.impl

  if (self.installed[unique_name]) then
    warn("Deployer:install(component_instance)   Component with name " .. unique_name .. " is already installed. Throwing exception")
    error( _orb:newexcept{ ALREADY_REGISTERED_EX, component_instance = component_instance } )
  end
  
  component_instance.role = self:checkInterfaces(role)
  
  info("Deployer:install(component_instance)   Everything ok, installing instance " .. unique_name)
  self.installed[unique_name] = component_instance
 
  debug("Deployer:install(component_instance) |-------------------------------- RETURNING --------------------------------------------|\n")
end

function Deployer:run( unique_name )
  debug("Deployer:run(unique_name) |------------------------------------------- INVOKED   --------------------------------------------|")
  if (not self.installed[unique_name]) then
    error( _orb:newexcept{ NOT_INSTALLED_EX, unique_name = unique_name } )
  end
  local instance = self.installed[unique_name]
  debug("Deployer:run(unique_name)   Acquired implementation, \"loadstring\" will be called")
  local ports = loadstring(instance.impl)()

  local startup  = ports.startup
  local shutdown = ports.shutdown
  ports.startup  = nil 
  ports.shutdown = nil

  local Component = deepcopy(scs.Component)
  -- Sets startup functions, if they were provided
  if (startup  ~= nil) then Component.startup  = startup  
  else warn("Deployer:run(unique_name)   No startup function was found for component " .. unique_name) startup = function() end end
  if (shutdown ~= nil) then Component.shutdown = shutdown 
  else warn("Deployer:run(unique_name)   No shutdown function was found for component " .. unique_name) shutdown = function() end end

  Component.startup  = startup
  Component.shutdown = shutdown

  local facets = {}
  facets.IComponent = {
    name           = ICOMPONENT_NAME,
    interface_name = IDL_ICOMPONENT,
    class          = Component,
    key            = unique_name,
    facet_ref      = _orb:newservant(Component, unique_name, IDL_ICOMPONENT)
  }
  local cp = {
    name = unique_name,
    major_version = 1,
    minor_version = 0,
    patch_version = 0,
    platform_spec = "",
  }

  debug("Deployer:run(unique_name)   Creating facets descriptions for component " .. unique_name)
  for name, service in pairs(instance.role.provided) do
    local interface_name = service.interface_name
    local interface = ports[name]
    if (not interface) then
      warn("Deployer:run(unique_name)   Could not find facet " .. name)
      error( _orb:newexcept{ NO_IMPLEMENTATION_EX, name = name, interface_name = interface_name } )
    else
      debug("Deployer:run(unique_name)   Creating description for facet " .. name .. " of type " .. interface_name)
      local key = unique_name .. "-" .. name
      facets[name] = {
        name           = name,
        interface_name = interface_name,
        class          = ports[name],
        key            = key,
        facet_ref      = _orb:newservant(ports[name], key, interface_name)
      }
    end
  end

  debug("Deployer:run(unique_name)   Creating receptacle descriptions for component " .. unique_name)
  local recepts = {}
  for name, service in pairs(instance.role.required) do
    local interface_name = service.interface_name
    debug("Deployer:run(unique_name)   Creating description for receptacle " .. name .. " of type " .. interface_name)
    local key = unique_name .. "-" .. name
    local is_multiplex = (service.arity == ONE_TO_MANY)
    recepts[name] = {
      name           = name,
      interface_name = interface_name,
      is_multiplex   = is_multiplex
    }
  end

  info("Deployer:run(unique_name)   Creating adaptive component " .. unique_name)
  local component, msg = scsAdaptive.newAdaptiveComponent(facets, recepts, cp, true)
  if (component == nil) then
    warn("Deployer:run(unique_name)   Some error occurred while creating the component: " .. unique_name)
    error( _orb:newexcept{ RUN_ERROR_EX, msg = msg } )
  else
    self.running[unique_name] = component
    info("Deployer:run(unique_name)   Component " .. unique_name .. " is now running on machine " .. ip)
    local component = _orb:narrow(facets.IComponent.facet_ref, IDL_ICOMPONENT)
    debug("Deployer:run(unique_name) |------------------------------------------- RETURNING --------------------------------------------|\n")
    return component
  end

end

function Deployer:checkInterfaces(role)
  debug("Deployer:checkInterfaces(role) INVOKED")
  local roleMap = {}
  roleMap.provided = {}
  roleMap.required = {}
  for k, service in pairs(role.provided) do
    if (k ~= "n" and not _orb.types:lookup_id( service.interface_name )) then
      local msg =  "ORB on machine " .. ip .. " cannot find interface " .. service.interface_name
      debug("Deployer:checkInterfaces(role) " .. msg)
      error( _orb:newexcept{ UNKNOWN_SERVICE_EX, msg = msg, service = service } )
    elseif (k ~= "n") then 
      debug("Deployer:checkInterfaces(role) Provided interface OK: " .. service.interface_name)
      roleMap.provided[service.name] = service
    end
  end
  for k, service in pairs(role.required) do
    if (k ~= "n" and not _orb.types:lookup_id( service.interface_name )) then
      local msg =  "ORB on machine " .. ip .. " cannot find interface " .. service.interface_name
      debug("Deployer:checkInterfaces(role) " .. msg)
      error( _orb:newexcept{ UNKNOWN_SERVICE_EX, msg = msg, service = service } )
    elseif (k ~= "n") then
      roleMap.required[service.name] = service
      debug("Deployer:checkInterfaces(role) Required interface OK: " .. service.interface_name)
    end
  end
  debug("Deployer:checkInterfaces(role) RETURNING")
  return roleMap
end

local Component = deepcopy(scs.Component)
--[[print(" ---------------------|||_|__|_|_|_|_|_|_|__|_||_|_|_|__|_|_|_|___|_|____|_|--------------------------- ")
table_print(Component)
print(" ---------------------|||_|__|_|_|_|_|_|_|__|_||_|_|_|__|_|_|_|___|_|____|_|--------------------------- ")
table_print(scs.Component)
print(" ---------------------|||_|__|_|_|_|_|_|_|__|_||_|_|_|__|_|_|_|___|_|____|_|--------------------------- ")
]]--
Component.startup = function (self)
  debug("Deployer:startup() |-------------------------------------------------- INVOKED   --------------------------------------------|")
  debug("Deployer:startup() |-------------------------------------------------- RETURNING --------------------------------------------|\n")
end
Component.shutdown = function (self)
  debug("Deployer:shutdown() |------------------------------------------------- INVOKED   --------------------------------------------|")
  for k, v in pairs(self.context) do
    if (type(k) == "string") and (k:sub(1,1) ~= "_") then
      info("Deployer:shutdown()   Deactivating " .. tostring(k) .. " servant")
      oil.pcall(oil.orb.deactivate, oil.orb, v)
    end
  end
  oil.newthread(function()
                  oil.sleep(3)
                  info("Deployer:shutdown()   Shutting down ORB")
                  _orb:shutdown()
                end)
  debug("Deployer:shutdown() |------------------------------------------------- RETURNING --------------------------------------------|\n")
end

local facetDescs = {}

facetDescs.IDeployer = {
  name           = DEPLOYER_FACET_NAME,
  interface_name = IDL_DEPLOYER,
  class          = Deployer,
  key            = DEPLOYER_KEY
}

facetDescs.IComponent = {
  name           = ICOMPONENT_NAME,
  interface_name = IDL_ICOMPONENT,
  class          = Component,
  key            = DEPLOYER_ICOMPONENT_KEY
}
--facetDescs.IComponent.facet_ref = _orb:newservant(component, IDL_ICOMPONENT, facetDescs.IComponent.key)

local cpId = {
--  name = DEPLOYER_COMPONENT_NAME .. "-" .. ip,
  name = DEPLOYER_COMPONENT_NAME,
  major_version = 1,
  minor_version = 0,
  patch_version = 0,
  platform_spec = ""
}
local receptDescs = {}

--
-- Description: Starts the execution of the deployer component
--
function startDeployer()
  debug("startDeployer() invoked")
  oil.newthread(_orb.run, _orb)
  --local deployer, msg = oil.pcall(scsAdaptive.newAdaptiveComponent, facetDescs, receptDescs, cpId, true)
  facetDescs.IComponent.facet_ref = _orb:newservant(facetDescs.IComponent.class, facetDescs.IComponent.key, IDL_ICOMPONENT)
  local deployer, msg = scsAdaptive.newAdaptiveComponent(facetDescs, receptDescs, cpId, true)
  if (not deployer) then
    error("Failed to start Deployer component:\n" .. msg)
  else
    info("startDeployer() Component " .. cpId.name .. " succesfully started\n")
  end
end

